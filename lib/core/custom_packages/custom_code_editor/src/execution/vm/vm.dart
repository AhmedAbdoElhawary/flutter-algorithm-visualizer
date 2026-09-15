/// The bytecode dispatch loop: an explicit heap-allocated frame stack (a
/// Dart `StackOverflowError` must never occur — G4), closures, classes,
/// exceptions, and budget/cancellation enforcement.
library;

import 'dart:collection';

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
  const VmResult({this.returned, this.stdout = const <String>[], this.truncated = false, this.failure});
  final Value? returned;
  final List<String> stdout;
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
        locals = List<Cell>.generate((closure.chunk as FunctionProto).maxLocals, (_) => Cell(NullValue.instance), growable: false);
  final FunctionValue closure;
  final FunctionProto proto;
  final List<Cell> locals;
  final List<Value> stack = <Value>[];
  int ip = 0;
}

class Vm {
  Vm({required this.dialect, required this.budget, bool Function()? isCancelled}) : _isCancelled = isCancelled ?? (() => false) {
    _globals.addAll(numbers.buildPreludeGlobals());
  }

  final Dialect dialect;
  final ExecutionBudget budget;
  final bool Function() _isCancelled;

  final Map<String, Value> _globals = <String, Value>{};
  final List<_Frame> _frames = <_Frame>[];
  final List<String> _stdout = <String>[];
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
      return VmResult(returned: result, stdout: List<String>.of(_stdout), truncated: _truncated);
    } on _EngineHalt catch (h) {
      return VmResult(
        stdout: List<String>.of(_stdout),
        truncated: _truncated,
        failure: Failure(kind: h.kind, code: h.code, line: _currentLine(), partialOutput: List<String>.of(_stdout)),
      );
    } on _Uncaught catch (u) {
      final v = u.value;
      final (code, data) = v is ErrorValue ? (v.code, v.data) : ('uncaughtThrow', <String, Object?>{'message': displayString(v, dialect)});
      return VmResult(
        stdout: List<String>.of(_stdout),
        truncated: _truncated,
        failure: Failure(kind: FailureKind.runtime, code: code, data: data, line: u.line, partialOutput: List<String>.of(_stdout)),
      );
    } on VmRuntimeError catch (e) {
      return VmResult(
        stdout: List<String>.of(_stdout),
        truncated: _truncated,
        failure: Failure(kind: FailureKind.runtime, code: e.code, data: e.data, line: _currentLine(), partialOutput: List<String>.of(_stdout)),
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
        if (receiver is! InstanceValue) throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'an object'});
        receiver.fields[name] = value;
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
      case OpCode.slice:
        throw const VmRuntimeError('unsupportedConstruct', <String, Object?>{'construct': 'slicing'});

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
        _binaryArith(frame, (a, b) => a * b);
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

      case OpCode.call:
        _call(_u8(frame));
      case OpCode.closure:
        _makeClosure(frame);
      case OpCode.ret:
        return _returnFromFrame(frame);
      case OpCode.print:
        _emitOutput(displayString(frame.stack.removeLast(), dialect));

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

  void _emitOutput(String line) {
    if (_stdout.length >= budget.maxOutputEntries || _outputChars >= budget.maxOutputChars) {
      _truncated = true;
      return;
    }
    _stdout.add(line);
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
      final i = _resolveIndex(index, receiver.items.length);
      return receiver.items[i];
    }
    if (receiver is TupleValue) {
      final i = _resolveIndex(index, receiver.items.length);
      return receiver.items[i];
    }
    if (receiver is StrValue) {
      final i = _resolveIndex(index, receiver.value.length);
      return dialect.stringIndexYields == StringIndexResult.codeUnit
          ? IntValue(receiver.value.codeUnitAt(i))
          : StrValue(receiver.value[i]);
    }
    if (receiver is MapValue) {
      final v = receiver.entries[index];
      if (v == null) throw VmRuntimeError('keyNotFound', <String, Object?>{'key': displayString(index, dialect)});
      return v;
    }
    throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'an indexable value'});
  }

  void _setIndex(Value receiver, Value index, Value value) {
    if (receiver is ListValue) {
      final i = _resolveIndex(index, receiver.items.length);
      receiver.items[i] = value;
      return;
    }
    if (receiver is MapValue) {
      receiver.entries[index] = value;
      return;
    }
    throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a mutable indexable value'});
  }

  int _resolveIndex(Value index, int length) {
    if (index is! IntValue) throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'an integer index'});
    var i = index.value;
    if (i < 0 && dialect.negativeIndexing) i += length;
    if (i < 0 || i >= length) throw VmRuntimeError('indexOutOfRange', <String, Object?>{'index': index.value, 'length': length});
    return i;
  }

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
      if (m == null) throw VmRuntimeError('undefinedVariable', <String, Object?>{'name': '${receiver.name}.$name'});
      return m;
    }
    if (receiver is ListValue) return collections.getListProperty(receiver.items, name) ?? IntrinsicMethod(receiver, name);
    if (receiver is TupleValue) return collections.getListProperty(receiver.items, name) ?? IntrinsicMethod(receiver, name);
    if (receiver is StrValue) return strings.getStringProperty(receiver.value, name, dialect) ?? IntrinsicMethod(receiver, name);
    if (receiver is MapValue) return maps.getMapProperty(receiver, name) ?? IntrinsicMethod(receiver, name);
    if (receiver is SetValue) return maps.getSetProperty(receiver, name) ?? IntrinsicMethod(receiver, name);
    if (receiver is IntValue || receiver is NumValue) return numbers.getNumberProperty(receiver, name) ?? IntrinsicMethod(receiver, name);
    throw VmRuntimeError('undefinedVariable', <String, Object?>{'name': name});
  }

  Value _callIntrinsic(IntrinsicMethod method, List<Value> args) {
    final receiver = method.receiver;
    final name = method.name;
    Value invoke(FunctionValue fn, List<Value> callArgs) => _callSync(fn, callArgs);
    if (receiver is ListValue) return collections.callListMethod(receiver, name, args, invoke, dialect);
    if (receiver is TupleValue) return collections.callListMethod(ListValue(receiver.items), name, args, invoke, dialect);
    if (receiver is StrValue) return strings.callStringMethod(receiver.value, name, args, invoke, dialect);
    if (receiver is MapValue) return maps.callMapMethod(receiver, name, args, invoke, dialect);
    if (receiver is SetValue) return maps.callSetMethod(receiver, name, args, invoke, dialect);
    if (receiver is IntValue || receiver is NumValue) return numbers.callNumberMethod(receiver, name, args, invoke, dialect);
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
    final args = List<Value>.generate(argCount, (i) => _frames.last.stack[_frames.last.stack.length - argCount + i]);
    _frames.last.stack.removeRange(_frames.last.stack.length - argCount, _frames.last.stack.length);
    final callee = _frames.last.stack.removeLast();

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
    if (args.length != proto.arity) {
      throw VmRuntimeError('wrongArgumentCount', <String, Object?>{'expected': proto.arity, 'actual': args.length});
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
      if (sc is! ClassValue) throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a class'});
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
    if (superclass == null) throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a superclass'});
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
