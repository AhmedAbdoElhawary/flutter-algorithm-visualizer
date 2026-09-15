/// The bytecode dispatch loop: an explicit heap-allocated frame stack (a
/// Dart `StackOverflowError` must never occur — G4), closures, classes,
/// exceptions, and budget/cancellation enforcement.
library;

import 'dart:collection';
import 'dart:math' as math;

import '../errors/failure.dart';
import '../stdlib/collections.dart' as collections;
import '../stdlib/maps.dart' as maps;
import '../stdlib/numbers.dart' as numbers;
import '../stdlib/strings.dart' as strings;
import '../values/canonical.dart';
import '../values/dialect.dart';
import '../values/value.dart';
import 'budget.dart';
import 'chunk.dart';

class VmResult {
  const VmResult(
      {this.returned,
      this.stdout = const <String>[],
      this.rawOutput = const <Value>[],
      this.truncated = false,
      this.failure});
  final Value? returned;
  final List<String> stdout;

  /// The raw evaluated value of each `print(...)` argument, parallel to
  /// [stdout]. Lets a caller grade the last printed value directly (e.g. a
  /// custom object) rather than its stringified form — used by the
  /// "learner wrote their own `main()`" fallback path in `testcase/`.
  final List<Value> rawOutput;
  final bool truncated;
  final Failure? failure;
}

/// Internal control-flow signal for an engine-imposed limit (time, memory,
/// recursion depth, cancellation) — never catchable by the learner's own
/// `try`/`catch`, unlike [VmRuntimeError] and a learner `throw`, both of
/// which unwind through the bytecode's exception table.
class _EngineHalt implements Exception {
  const _EngineHalt(this.kind, this.code);
  final FailureKind kind;
  final String code;
}

class _Frame {
  _Frame(this.closure)
      : proto = closure.chunk as FunctionProto,
        locals = List<Cell>.generate(
            (closure.chunk as FunctionProto).maxLocals, (_) => Cell(NullValue.instance),
            growable: false);
  final FunctionValue closure;
  final FunctionProto proto;
  final List<Cell> locals;
  final List<Value> stack = <Value>[];
  int ip = 0;
}

class Vm {
  Vm({required this.dialect, required this.budget, bool Function()? isCancelled})
      : _isCancelled = isCancelled ?? (() => false) {
    _globals.addAll(numbers.buildPreludeGlobals());
  }

  final Dialect dialect;
  final ExecutionBudget budget;
  final bool Function() _isCancelled;

  final Map<String, Value> _globals = <String, Value>{};
  final List<_Frame> _frames = <_Frame>[];
  final List<String> _stdout = <String>[];
  final List<Value> _rawOutput = <Value>[];
  int _outputChars = 0;
  bool _truncated = false;
  int _instructionCount = 0;
  late final Stopwatch _stopwatch;
  Duration _timeout = const Duration(seconds: 2);

  void defineGlobal(String name, Value value) => _globals[name] = value;

  /// Runs [script] to completion (or until it throws, times out, is
  /// cancelled, or exceeds a resource limit) and returns a [VmResult].
  /// Never throws — every failure path is captured and classified.
  VmResult run(FunctionValue script, {required Duration timeout}) {
    _timeout = timeout;
    _stopwatch = Stopwatch()..start();
    _frames.add(_Frame(script));
    try {
      final result = _dispatchLoop(0);
      return VmResult(
          returned: result,
          stdout: List<String>.of(_stdout),
          rawOutput: List<Value>.of(_rawOutput),
          truncated: _truncated);
    } on _EngineHalt catch (h) {
      return VmResult(
        stdout: List<String>.of(_stdout),
        truncated: _truncated,
        failure: Failure(
            kind: h.kind, code: h.code, line: _currentLine(), partialOutput: List<String>.of(_stdout)),
      );
    } on _Uncaught catch (u) {
      final v = u.value;
      final (code, data) = v is ErrorValue
          ? (v.code, v.data)
          : ('uncaughtThrow', <String, Object?>{'message': displayString(v, dialect)});
      return VmResult(
        stdout: List<String>.of(_stdout),
        truncated: _truncated,
        failure: Failure(
            kind: FailureKind.runtime,
            code: code,
            data: data,
            line: u.line,
            partialOutput: List<String>.of(_stdout)),
      );
    } on VmRuntimeError catch (e) {
      return VmResult(
        stdout: List<String>.of(_stdout),
        truncated: _truncated,
        failure: Failure(
            kind: FailureKind.runtime,
            code: e.code,
            data: e.data,
            line: _currentLine(),
            partialOutput: List<String>.of(_stdout)),
      );
    }
  }

  int _currentLine() {
    if (_frames.isEmpty) return 0;
    final f = _frames.last;
    final ip = f.ip == 0 ? 0 : f.ip - 1;
    if (ip < 0 || ip >= f.proto.chunk.lines.length) return 0;
    return f.proto.chunk.lines[ip];
  }

  /// Runs instructions until `_frames.length == stopAtFrameCount`. A regular
  /// top-level run passes `0` (run to completion). A native intrinsic that
  /// needs to call back into a learner closure (`.map`, `.sort(cmp)`, ...)
  /// passes `_frames.length` *before* pushing the callback's frame, so this
  /// recurses only as deep as the learner's own syntactic nesting of such
  /// callbacks — never proportional to input size, unlike ordinary user
  /// recursion (which this loop handles without any Dart-level recursion at
  /// all, by pushing/popping `_frames` in place — see [OpCode.call]).
  Value? _dispatchLoop(int stopAtFrameCount) {
    while (_frames.length > stopAtFrameCount) {
      final returned = _step();
      if (returned != null) {
        // A RET just popped a frame. If a frame above `stopAtFrameCount`
        // remains, that's a normal bytecode caller — resume it by pushing
        // the value onto its stack (the same place a CALL result always
        // lands). If we're exactly at the target depth, this value is what
        // *our* caller (`run`, or a `_callSync` reentering for an intrinsic
        // callback) is waiting for.
        if (_frames.length > stopAtFrameCount) {
          _frames.last.stack.add(returned);
        } else {
          return returned;
        }
      }
    }
    return null;
  }

  Value? _step() {
    _instructionCount++;
    if (_instructionCount % budget.instructionsPerBudgetCheck == 0) {
      if (_isCancelled()) throw const _EngineHalt(FailureKind.cancelled, 'cancelled');
      if (_stopwatch.elapsed > _timeout) throw const _EngineHalt(FailureKind.timeLimit, 'timeLimitExceeded');
    }

    final frame = _frames.last;
    final code = frame.proto.chunk.code;
    final faultLine = frame.ip < frame.proto.chunk.lines.length ? frame.proto.chunk.lines[frame.ip] : 0;
    final faultPc = frame.ip;
    final op = code[frame.ip++];

    try {
      return _execute(frame, op);
    } on VmRuntimeError catch (e) {
      _throwValue(ErrorValue(code: e.code, data: e.data), faultPc, faultLine);
      return null;
    } on _Uncaught {
      rethrow;
    }
  }

  int _u16(_Frame f) {
    final code = f.proto.chunk.code;
    final v = (code[f.ip] << 8) | code[f.ip + 1];
    f.ip += 2;
    return v;
  }

  int _u8(_Frame f) => f.proto.chunk.code[f.ip++];

  Value? _execute(_Frame frame, int op) {
    switch (op) {
      case OpCode.constant:
        frame.stack.add(frame.proto.chunk.constants[_u16(frame)]);
      case OpCode.nullLit:
        frame.stack.add(NullValue.instance);
      case OpCode.trueLit:
        frame.stack.add(BoolValue.trueValue);
      case OpCode.falseLit:
        frame.stack.add(BoolValue.falseValue);
      case OpCode.pop:
        frame.stack.removeLast();
      case OpCode.dup:
        frame.stack.add(frame.stack.last);

      case OpCode.getLocal:
        frame.stack.add(frame.locals[_u16(frame)].value);
      case OpCode.setLocal:
        frame.locals[_u16(frame)].value = frame.stack.last;
      case OpCode.getUpvalue:
        frame.stack.add(frame.closure.upvalues[_u16(frame)].value);
      case OpCode.setUpvalue:
        frame.closure.upvalues[_u16(frame)].value = frame.stack.last;
      case OpCode.getGlobal:
        final name = (frame.proto.chunk.constants[_u16(frame)] as StrValue).value;
        final v = _globals[name];
        if (v == null) throw VmRuntimeError('undefinedVariable', <String, Object?>{'name': name});
        frame.stack.add(v);
      case OpCode.setGlobal:
        final name = (frame.proto.chunk.constants[_u16(frame)] as StrValue).value;
        _globals[name] = frame.stack.last;
      case OpCode.defineGlobal:
        final name = (frame.proto.chunk.constants[_u16(frame)] as StrValue).value;
        _globals[name] = frame.stack.removeLast();

      case OpCode.getProperty:
        final name = (frame.proto.chunk.constants[_u16(frame)] as StrValue).value;
        final receiver = frame.stack.removeLast();
        frame.stack.add(_getProperty(receiver, name));
      case OpCode.setProperty:
        final name = (frame.proto.chunk.constants[_u16(frame)] as StrValue).value;
        final value = frame.stack.removeLast();
        final receiver = frame.stack.removeLast();
        if (receiver is InstanceValue) {
          receiver.fields[name] = value;
        } else if (receiver is MapValue && dialect.propertyAccessReadsMapKeys) {
          receiver.entries[StrValue(name)] = value;
        } else {
          throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'an object'});
        }
        frame.stack.add(value);
      case OpCode.getIndex:
        final index = frame.stack.removeLast();
        final receiver = frame.stack.removeLast();
        frame.stack.add(_getIndex(receiver, index));
      case OpCode.setIndex:
        final value = frame.stack.removeLast();
        final index = frame.stack.removeLast();
        final receiver = frame.stack.removeLast();
        _setIndex(receiver, index, value);
        frame.stack.add(value);
      case OpCode.iterElement:
        final at = frame.stack.removeLast();
        final over = frame.stack.removeLast();
        frame.stack.add(_iterElement(over, at));
      case OpCode.slice:
        final flags = _u8(frame);
        // Pushed by the compiler in receiver, start, end, step order, so they
        // come back off the stack in reverse.
        final step = (flags & 4) != 0 ? frame.stack.removeLast() : null;
        final end = (flags & 2) != 0 ? frame.stack.removeLast() : null;
        final start = (flags & 1) != 0 ? frame.stack.removeLast() : null;
        final sliceTarget = frame.stack.removeLast();
        frame.stack.add(_slice(sliceTarget, start, end, step));

      case OpCode.equal:
        final b = frame.stack.removeLast();
        final a = frame.stack.removeLast();
        frame.stack.add(BoolValue(_valuesEqual(a, b)));
      case OpCode.notEqual:
        final b = frame.stack.removeLast();
        final a = frame.stack.removeLast();
        frame.stack.add(BoolValue(!_valuesEqual(a, b)));
      case OpCode.greater:
        final b = frame.stack.removeLast();
        final a = frame.stack.removeLast();
        frame.stack.add(BoolValue(compareValues(a, b, dialect) > 0));
      case OpCode.greaterEqual:
        final b = frame.stack.removeLast();
        final a = frame.stack.removeLast();
        frame.stack.add(BoolValue(compareValues(a, b, dialect) >= 0));
      case OpCode.less:
        final b = frame.stack.removeLast();
        final a = frame.stack.removeLast();
        frame.stack.add(BoolValue(compareValues(a, b, dialect) < 0));
      case OpCode.lessEqual:
        final b = frame.stack.removeLast();
        final a = frame.stack.removeLast();
        frame.stack.add(BoolValue(compareValues(a, b, dialect) <= 0));

      case OpCode.add:
        _binaryAdd(frame);
      case OpCode.subtract:
        _binaryArith(frame, (a, b) => a - b);
      case OpCode.multiply:
        _binaryMultiply(frame);
      case OpCode.divide:
        _binaryDivide(frame);
      case OpCode.floorDivide:
        _binaryIntArith(frame, (a, b) {
          if (b == 0) throw const VmRuntimeError('divisionByZero');
          return (a / b).floor();
        });
      case OpCode.truncDivide:
        _binaryIntArith(frame, (a, b) {
          if (b == 0) throw const VmRuntimeError('divisionByZero');
          return a ~/ b;
        });
      case OpCode.modulo:
        _binaryIntArith(frame, (a, b) {
          if (b == 0) throw const VmRuntimeError('divisionByZero');
          return a % b;
        });
      case OpCode.power:
        _binaryPower(frame);
      case OpCode.negate:
        final v = frame.stack.removeLast();
        if (v is IntValue) {
          frame.stack.add(IntValue(-v.value));
        } else if (v is NumValue) {
          frame.stack.add(NumValue(-v.value));
        } else {
          throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a number'});
        }
      case OpCode.not:
        final v = frame.stack.removeLast();
        frame.stack.add(BoolValue(!isTruthy(v, dialect)));
      case OpCode.isNullish:
        final v = frame.stack.removeLast();
        frame.stack.add(BoolValue(v is NullValue || v is UndefinedValue));
      case OpCode.stringify:
        final v = frame.stack.removeLast();
        frame.stack.add(StrValue(displayString(v, dialect)));
      case OpCode.buildString:
        final count = _u16(frame);
        final parts = frame.stack.sublist(frame.stack.length - count);
        frame.stack.removeRange(frame.stack.length - count, frame.stack.length);
        frame.stack.add(StrValue(parts.map((p) => (p as StrValue).value).join()));

      case OpCode.jump:
        frame.ip = _u16(frame);
      case OpCode.jumpIfFalse:
        final target = _u16(frame);
        if (!isTruthy(frame.stack.removeLast(), dialect)) frame.ip = target;
      case OpCode.jumpIfTrue:
        final target = _u16(frame);
        if (isTruthy(frame.stack.removeLast(), dialect)) frame.ip = target;

      case OpCode.buildList:
        final count = _u16(frame);
        final items = frame.stack.sublist(frame.stack.length - count);
        frame.stack.removeRange(frame.stack.length - count, frame.stack.length);
        frame.stack.add(ListValue(items));
      case OpCode.buildTuple:
        final count = _u16(frame);
        final items = frame.stack.sublist(frame.stack.length - count);
        frame.stack.removeRange(frame.stack.length - count, frame.stack.length);
        frame.stack.add(TupleValue(items));
      case OpCode.buildMap:
        final pairCount = _u16(frame);
        final map = MapValue();
        final start = frame.stack.length - pairCount * 2;
        for (var i = 0; i < pairCount; i++) {
          map.entries[frame.stack[start + i * 2]] = frame.stack[start + i * 2 + 1];
        }
        frame.stack.removeRange(start, frame.stack.length);
        frame.stack.add(map);
      case OpCode.buildSet:
        final count = _u16(frame);
        final items = frame.stack.sublist(frame.stack.length - count);
        frame.stack.removeRange(frame.stack.length - count, frame.stack.length);
        frame.stack.add(SetValue(LinkedHashSet<Value>.of(items)));

      case OpCode.appendOne:
        final item = frame.stack.removeLast();
        (frame.stack.last as ListValue).items.add(item);
      case OpCode.extendAll:
        final source = frame.stack.removeLast();
        final into = frame.stack.last;
        if (into is SetValue) {
          into.items.addAll(_iterableOf(source));
        } else {
          (into as ListValue).items.addAll(_iterableOf(source));
        }
      case OpCode.callSpread:
        _callSpread();

      case OpCode.call:
        _call(_u8(frame));
      case OpCode.closure:
        _makeClosure(frame);
      case OpCode.ret:
        return _returnFromFrame(frame);
      case OpCode.print:
        final value = frame.stack.removeLast();
        _emitOutput(displayString(value, dialect), value);

      case OpCode.classDecl:
        _buildClass(frame);
      case OpCode.method:
        _addMethod(frame);
      case OpCode.superCall:
        _superCall(frame);
      case OpCode.throwOp:
        final value = frame.stack.removeLast();
        _throwValue(value, frame.ip - 1, frame.proto.chunk.lines[frame.ip - 1]);
    }
    return null;
  }

  void _emitOutput(String line, Value raw) {
    if (_stdout.length >= budget.maxOutputEntries || _outputChars >= budget.maxOutputChars) {
      _truncated = true;
      return;
    }
    _stdout.add(line);
    _rawOutput.add(raw);
    _outputChars += line.length;
  }

  bool _valuesEqual(Value a, Value b) {
    if (dialect.equalityCoerces) {
      if ((a is IntValue || a is NumValue) && (b is IntValue || b is NumValue)) {
        return compareValues(a, b, dialect) == 0;
      }
    }
    return a == b;
  }

  void _binaryAdd(_Frame frame) {
    final b = frame.stack.removeLast();
    final a = frame.stack.removeLast();
    if (a is StrValue && b is StrValue) {
      frame.stack.add(StrValue(a.value + b.value));
      return;
    }
    if (a is ListValue && b is ListValue) {
      frame.stack.add(ListValue(<Value>[...a.items, ...b.items]));
      return;
    }
    if (a is IntValue && b is IntValue) {
      frame.stack.add(IntValue(a.value + b.value));
      return;
    }
    if ((a is IntValue || a is NumValue) && (b is IntValue || b is NumValue)) {
      frame.stack.add(NumValue(_asDouble(a) + _asDouble(b)));
      return;
    }
    throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'matching operand types for +'});
  }

  /// `*`, which in Python also repeats a sequence — `[0] * n` is how a zeroed
  /// list gets built, and it is far too common to leave out.
  void _binaryMultiply(_Frame frame) {
    if (dialect.sequenceRepetition) {
      final b = frame.stack.last;
      final a = frame.stack[frame.stack.length - 2];
      final (Value sequence, Value count) = switch ((a, b)) {
        (IntValue(), ListValue() || StrValue()) => (b, a),
        (ListValue() || StrValue(), IntValue()) => (a, b),
        _ => (NullValue.instance, NullValue.instance),
      };
      if (count is IntValue) {
        frame.stack.removeLast();
        frame.stack.removeLast();
        final times = count.value < 0 ? 0 : count.value;
        if (sequence is StrValue) {
          frame.stack.add(StrValue(sequence.value * times));
        } else {
          final items = (sequence as ListValue).items;
          frame.stack.add(ListValue(<Value>[for (var i = 0; i < times; i++) ...items]));
        }
        return;
      }
    }
    _binaryArith(frame, (a, b) => a * b);
  }

  void _binaryArith(_Frame frame, double Function(double, double) op) {
    final b = frame.stack.removeLast();
    final a = frame.stack.removeLast();
    if (a is IntValue && b is IntValue) {
      frame.stack.add(IntValue(op(a.value.toDouble(), b.value.toDouble()).toInt()));
      return;
    }
    frame.stack.add(NumValue(op(_asDouble(a), _asDouble(b))));
  }

  void _binaryIntArith(_Frame frame, int Function(int, int) op) {
    final b = frame.stack.removeLast();
    final a = frame.stack.removeLast();
    if (a is IntValue && b is IntValue) {
      frame.stack.add(IntValue(op(a.value, b.value)));
      return;
    }
    throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'two integers'});
  }

  /// `a ** b`. Two whole numbers and a non-negative exponent stay whole — so
  /// Python's `2 ** 10` is `1024`, not `1024.0` — via repeated squaring,
  /// which keeps even a huge exponent to about 60 iterations. Anything else
  /// falls back to floating point.
  void _binaryPower(_Frame frame) {
    final b = frame.stack.removeLast();
    final a = frame.stack.removeLast();
    if (a is IntValue && b is IntValue && b.value >= 0) {
      var result = 1;
      var base = a.value;
      var exp = b.value;
      while (exp > 0) {
        if (exp & 1 == 1) result *= base;
        base *= base;
        exp >>= 1;
      }
      frame.stack.add(IntValue(result));
      return;
    }
    frame.stack.add(NumValue(math.pow(_asDouble(a), _asDouble(b)).toDouble()));
  }

  void _binaryDivide(_Frame frame) {
    final b = frame.stack.removeLast();
    final a = frame.stack.removeLast();
    final bd = _asDouble(b);
    if (bd == 0) throw const VmRuntimeError('divisionByZero');
    frame.stack.add(NumValue(_asDouble(a) / bd));
  }

  double _asDouble(Value v) {
    if (v is IntValue) return v.value.toDouble();
    if (v is NumValue) return v.value;
    throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a number'});
  }

  Value _getIndex(Value receiver, Value index) {
    if (receiver is ListValue) {
      final i = _resolveIndex(index, receiver.items.length, readOnly: true);
      return i == null ? UndefinedValue.instance : receiver.items[i];
    }
    if (receiver is TupleValue) {
      final i = _resolveIndex(index, receiver.items.length, readOnly: true);
      return i == null ? UndefinedValue.instance : receiver.items[i];
    }
    if (receiver is SetValue) {
      // Real Dart iterates a `Set` via its `Iterator`, not `[]` (which
      // `Set` doesn't even define) — this engine's `for (x in aSet)`
      // desugars to cursor-based indexing (`compile/compiler.dart`'s
      // `_compileForIn`),
      // so `[]` needs to work for a `LinkedHashSet` too. Insertion order
      // makes `elementAt` well-defined.
      final i = _requireIndex(index, receiver.items.length);
      return receiver.items.elementAt(i);
    }
    if (receiver is StrValue) {
      final i = _resolveIndex(index, receiver.value.length, readOnly: true);
      if (i == null) return UndefinedValue.instance;
      return dialect.stringIndexYields == StringIndexResult.codeUnit
          ? IntValue(receiver.value.codeUnitAt(i))
          : StrValue(receiver.value[i]);
    }
    if (receiver is MapValue) {
      // Dart's `Map[]` never throws for a missing key — it returns `null`
      // (unlike `List[]`, which does bounds-check). `m[k] ?? 0` is the
      // idiomatic default-value pattern this depends on.
      return receiver.entries[index] ?? NullValue.instance;
    }
    throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'an indexable value'});
  }

  void _setIndex(Value receiver, Value index, Value value) {
    if (receiver is ListValue) {
      // Writing past the end grows the array in a language where reading
      // past it is not an error either — `xs[xs.length] = v` is a normal way
      // to append in JavaScript.
      if (dialect.outOfRangeIndexIsUndefined && index is IntValue && index.value >= receiver.items.length) {
        while (receiver.items.length < index.value) {
          receiver.items.add(UndefinedValue.instance);
        }
        receiver.items.add(value);
        return;
      }
      final i = _requireIndex(index, receiver.items.length);
      receiver.items[i] = value;
      return;
    }
    if (receiver is MapValue) {
      receiver.entries[index] = value;
      return;
    }
    throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a mutable indexable value'});
  }

  /// The element at [position] in iteration order, which for a map means its
  /// *keys* — `for k in d` walks keys, even though `d[k]` looks values up.
  Value _iterElement(Value over, Value position) {
    if (over is MapValue) {
      final i = _requireIndex(position, over.entries.length);
      return over.entries.keys.elementAt(i);
    }
    return _getIndex(over, position);
  }

  /// Every element of a value that can be spread or iterated over.
  List<Value> _iterableOf(Value source) {
    if (source is ListValue) return source.items;
    if (source is TupleValue) return source.items;
    if (source is SetValue) return source.items.toList();
    if (source is StrValue) return <Value>[for (final c in source.value.split('')) StrValue(c)];
    throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'an iterable'});
  }

  /// `a[start:end:step]`. Follows Python's rules, which are the only ones the
  /// engine needs: omitted bounds default by the sign of [step], out-of-range
  /// bounds **clamp** rather than raising (unlike plain `[]` indexing), and
  /// negative bounds count from the end.
  Value _slice(Value receiver, Value? start, Value? end, Value? step) {
    final int length;
    if (receiver is ListValue) {
      length = receiver.items.length;
    } else if (receiver is TupleValue) {
      length = receiver.items.length;
    } else if (receiver is StrValue) {
      length = receiver.value.length;
    } else {
      throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a sliceable value'});
    }

    final stride = step == null ? 1 : _sliceBound(step);
    if (stride == 0) {
      throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a non-zero slice step'});
    }

    int clamp(int raw) {
      var i = raw;
      if (i < 0) {
        i += length;
        if (i < 0) i = stride < 0 ? -1 : 0;
      } else if (i > length) {
        i = stride < 0 ? length - 1 : length;
      }
      return i;
    }

    final from = start == null ? (stride < 0 ? length - 1 : 0) : clamp(_sliceBound(start));
    final to = end == null ? (stride < 0 ? -1 : length) : clamp(_sliceBound(end));

    final picked = <int>[];
    for (var i = from; stride > 0 ? i < to : i > to; i += stride) {
      picked.add(i);
    }

    if (receiver is StrValue) {
      return StrValue(<String>[for (final i in picked) receiver.value[i]].join());
    }
    final items = receiver is ListValue ? receiver.items : (receiver as TupleValue).items;
    final sliced = <Value>[for (final i in picked) items[i]];
    return receiver is TupleValue ? TupleValue(sliced) : ListValue(sliced);
  }

  int _sliceBound(Value v) {
    if (v is IntValue) return v.value;
    throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'an integer slice bound'});
  }

  /// Resolves an index, or returns null when it is out of range and the
  /// language says that is not an error — JavaScript's `[1, 2][9]` is
  /// `undefined`, which is why a JavaScript off-by-one surfaces as a strange
  /// answer rather than as a crash. [readOnly] is false for writes, which
  /// still bounds-check everywhere.
  int? _resolveIndex(Value index, int length, {bool readOnly = false}) {
    if (index is! IntValue) {
      if (readOnly && dialect.outOfRangeIndexIsUndefined) return null;
      throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'an integer index'});
    }
    var i = index.value;
    if (i < 0 && dialect.negativeIndexing) i += length;
    if (i < 0 || i >= length) {
      if (readOnly && dialect.outOfRangeIndexIsUndefined) return null;
      throw VmRuntimeError('indexOutOfRange', <String, Object?>{'index': index.value, 'length': length});
    }
    return i;
  }

  /// The bounds-checking form, for the callers that must always fail on a bad
  /// index (writes, and every indexable that is not a list).
  int _requireIndex(Value index, int length) => _resolveIndex(index, length)!;

  Value _getProperty(Value receiver, String name) {
    if (receiver is InstanceValue) {
      final field = receiver.fields[name];
      if (field != null) return field;
      final method = receiver.klass.findMethod(name);
      if (method != null) return method.bindTo(receiver);
      return NullValue.instance;
    }
    if (receiver is NamespaceValue) {
      final m = receiver.members[name];
      if (m == null) {
        throw VmRuntimeError('undefinedVariable', <String, Object?>{'name': '${receiver.name}.$name'});
      }
      return m;
    }
    if (receiver is ListValue) {
      return collections.getListProperty(receiver.items, name) ?? IntrinsicMethod(receiver, name);
    }
    if (receiver is TupleValue) {
      return collections.getListProperty(receiver.items, name) ?? IntrinsicMethod(receiver, name);
    }
    if (receiver is StrValue) {
      return strings.getStringProperty(receiver.value, name, dialect) ?? IntrinsicMethod(receiver, name);
    }
    if (receiver is MapValue) {
      // In a language whose objects are maps, `o.b` and `o["b"]` are the same
      // lookup — but only after the real map members, so `o.length` still
      // means the size rather than an entry that happens to be called that.
      final member = maps.getMapProperty(receiver, name);
      if (member != null) return member;
      if (dialect.propertyAccessReadsMapKeys) {
        final entry = receiver.entries[StrValue(name)];
        if (entry != null) return entry;
      }
      return IntrinsicMethod(receiver, name);
    }
    if (receiver is SetValue) return maps.getSetProperty(receiver, name) ?? IntrinsicMethod(receiver, name);
    if (receiver is IntValue || receiver is NumValue) {
      return numbers.getNumberProperty(receiver, name) ?? IntrinsicMethod(receiver, name);
    }
    throw VmRuntimeError('undefinedVariable', <String, Object?>{'name': name});
  }

  Value _callIntrinsic(IntrinsicMethod method, List<Value> args) {
    final receiver = method.receiver;
    final name = method.name;
    Value invoke(FunctionValue fn, List<Value> callArgs) => _callSync(fn, callArgs);
    if (receiver is ListValue) return collections.callListMethod(receiver, name, args, invoke, dialect);
    if (receiver is TupleValue) {
      return collections.callListMethod(ListValue(receiver.items), name, args, invoke, dialect);
    }
    if (receiver is StrValue) return strings.callStringMethod(receiver.value, name, args, invoke, dialect);
    if (receiver is MapValue) return maps.callMapMethod(receiver, name, args, invoke, dialect);
    if (receiver is SetValue) return maps.callSetMethod(receiver, name, args, invoke, dialect);
    if (receiver is IntValue || receiver is NumValue) {
      return numbers.callNumberMethod(receiver, name, args, invoke, dialect);
    }
    throw VmRuntimeError('undefinedFunction', <String, Object?>{'name': name});
  }

  /// Invokes [fn] synchronously and returns its result, for stdlib
  /// intrinsics that need to call back into a learner closure. See
  /// [_dispatchLoop]'s doc comment for why this bounded reentrancy is safe.
  Value _callSync(FunctionValue fn, List<Value> args) {
    _pushCallFrame(fn, args);
    final result = _dispatchLoop(_frames.length - 1);
    return result ?? NullValue.instance;
  }

  void _call(int argCount) {
    final args =
        List<Value>.generate(argCount, (i) => _frames.last.stack[_frames.last.stack.length - argCount + i]);
    _frames.last.stack.removeRange(_frames.last.stack.length - argCount, _frames.last.stack.length);
    final callee = _frames.last.stack.removeLast();
    _invoke(callee, args);
  }

  /// The spread-aware call form: the argument list was assembled at runtime
  /// (`f(...xs, y)`) rather than counted at compile time, so it arrives as a
  /// single [ListValue] on top of the callee instead of as loose stack slots.
  void _callSpread() {
    final packed = _frames.last.stack.removeLast();
    if (packed is! ListValue) {
      throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'an argument list'});
    }
    final callee = _frames.last.stack.removeLast();
    _invoke(callee, List<Value>.of(packed.items));
  }

  void _invoke(Value callee, List<Value> args) {
    if (callee is FunctionValue) {
      _pushCallFrame(callee, args);
      return;
    }
    if (callee is ClassValue) {
      final instance = InstanceValue(callee);
      final init = callee.findMethod('<init>');
      if (init != null) {
        _callSync(init.bindTo(instance), args);
      }
      _frames.last.stack.add(instance);
      return;
    }
    if (callee is IntrinsicMethod) {
      _frames.last.stack.add(_callIntrinsic(callee, args));
      return;
    }
    if (callee is NativeFunctionValue) {
      _frames.last.stack.add(callee.call(args, _callSync));
      return;
    }
    throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a callable value'});
  }

  void _pushCallFrame(FunctionValue fn, List<Value> args) {
    if (_frames.length >= budget.maxFrameDepth) {
      throw const _EngineHalt(FailureKind.recursionLimit, 'recursionLimitExceeded');
    }
    final proto = fn.chunk as FunctionProto;
    if (args.length < proto.minArity || args.length > proto.arity) {
      throw VmRuntimeError(
          'wrongArgumentCount', <String, Object?>{'expected': proto.arity, 'actual': args.length});
    }
    final frame = _Frame(fn);
    var slot = 0;
    if (fn.boundThis != null) {
      frame.locals[slot++].value = fn.boundThis!;
    }
    for (final a in args) {
      frame.locals[slot++].value = a;
    }
    _frames.add(frame);
  }

  Value _returnFromFrame(_Frame frame) {
    final result = frame.stack.removeLast();
    _frames.removeLast();
    return result;
  }

  void _makeClosure(_Frame frame) {
    final protoCarrier = frame.proto.chunk.constants[_u16(frame)] as FunctionValue;
    final proto = protoCarrier.chunk as FunctionProto;
    final upvalues = proto.upvalues
        .map((d) => d.isLocal ? frame.locals[d.index] : frame.closure.upvalues[d.index])
        .toList(growable: false);
    frame.stack.add(FunctionValue(name: proto.name, arity: proto.arity, chunk: proto, upvalues: upvalues));
  }

  void _buildClass(_Frame frame) {
    final nameIdx = _u16(frame);
    final hasSuperclass = _u8(frame) != 0;
    final name = (frame.proto.chunk.constants[nameIdx] as StrValue).value;
    ClassValue? superclass;
    if (hasSuperclass) {
      final sc = frame.stack.removeLast();
      if (sc is! ClassValue) {
        throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a class'});
      }
      superclass = sc;
    }
    frame.stack.add(ClassValue(name: name, superclass: superclass));
  }

  void _addMethod(_Frame frame) {
    final nameIdx = _u16(frame);
    final name = (frame.proto.chunk.constants[nameIdx] as StrValue).value;
    final method = frame.stack.removeLast() as FunctionValue;
    final klass = frame.stack.last as ClassValue;
    method.homeClass = klass;
    klass.methods[name] = method;
  }

  void _superCall(_Frame frame) {
    final nameIdx = _u16(frame);
    final argCount = _u8(frame);
    final name = (frame.proto.chunk.constants[nameIdx] as StrValue).value;
    final args = List<Value>.generate(argCount, (i) => frame.stack[frame.stack.length - argCount + i]);
    frame.stack.removeRange(frame.stack.length - argCount, frame.stack.length);

    final homeClass = frame.closure.homeClass;
    final superclass = homeClass?.superclass;
    if (superclass == null) {
      throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a superclass'});
    }
    final method = superclass.findMethod(name);
    final thisValue = frame.locals[0].value;
    if (method == null || thisValue is! InstanceValue) {
      throw VmRuntimeError('undefinedFunction', <String, Object?>{'name': name});
    }
    frame.stack.add(_callSync(method.bindTo(thisValue), args));
  }

  void _throwValue(Value value, int faultPc, int faultLine) {
    while (_frames.isNotEmpty) {
      final frame = _frames.last;
      final handler = _findHandler(frame.proto.exceptionTable, faultPc);
      if (handler != null) {
        frame.stack.clear();
        frame.stack.add(value);
        frame.ip = handler.catchPc;
        return;
      }
      _frames.removeLast();
      if (_frames.isNotEmpty) {
        faultPc = _frames.last.ip == 0 ? 0 : _frames.last.ip - 1;
      }
    }
    throw _Uncaught(value, faultLine);
  }

  ExceptionHandler? _findHandler(List<ExceptionHandler> table, int pc) {
    ExceptionHandler? best;
    for (final h in table) {
      if (pc >= h.startPc && pc < h.endPc) {
        if (best == null || (h.endPc - h.startPc) < (best.endPc - best.startPc)) best = h;
      }
    }
    return best;
  }
}

class _Uncaught implements Exception {
  const _Uncaught(this.value, this.line);
  final Value value;
  final int line;
}

/// Grades a raw [Value] against a canonical expected value. Exposed here so
/// callers outside the VM (e.g. `testcase/`) don't need to import
/// `values/canonical.dart` directly for the common case.
CanonicalValue normalizeValue(Value v) => normalize(v);
