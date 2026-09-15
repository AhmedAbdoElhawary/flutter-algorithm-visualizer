/// Python's builtin functions, expressed on top of the shared value model.
///
/// The engine's own stdlib (`stdlib/collections.dart` and friends) is named
/// the Dart way — `.length`, `.toUpperCase()`, `.where()`. Python spells the
/// same operations differently, and in places means something different by
/// them. Bridging that is this directory's job, not the shared runtime's
/// (contract obligation O5, FR-031): everything here is built out of public
/// `Value` types, and nothing in `vm/` or `stdlib/` knows Python exists.
///
/// Two halves:
///
/// * [pythonGlobals] — the free functions (`len`, `range`, `sorted`, ...).
/// * [pythonMethodAliases] — the method renames the parser applies, so that
///   `xs.append(1)` reaches the shared `add` intrinsic.
library;

import 'dart:collection';

import '../../errors/failure.dart';
import '../../values/value.dart';
import 'python_collections.dart';
import 'python_dialect.dart';

/// Python methods the engine spells as a **property**: `d.keys()` is a call
/// in Python but `d.keys` is a plain getter here, so the parser drops the
/// call rather than trying to invoke the list that comes back.
const Set<String> pythonPropertyMethods = <String>{'keys', 'values'};

/// Every Python method the frontend translates, mapped to the helper global
/// that implements it. The helper takes the receiver as its first argument.
///
/// These are *not* plain renames onto the shared stdlib, even where a rename
/// would be enough. A learner who writes `class Stack` with a `pop` method,
/// or `class LinkedList` with `append`, must get their own method — and the
/// parser cannot tell what a receiver will be at runtime. Routing everything
/// through a helper means one place makes that decision, with the value in
/// hand: see [_userDefined].
///
/// A method that is not listed here is left exactly as the learner wrote it,
/// so their own methods, and the names Python and the engine already agree
/// on (`add` on a set), keep working untouched.
const Map<String, String> pythonMethodHelpers = <String, String>{
  // list
  'append': '__append',
  'extend': '__extend',
  'insert': '__insert',
  'pop': '__pop',
  'remove': '__remove',
  'sort': '__sort',
  'reverse': '__reverse',
  'index': '__index_of',
  'count': '__count',
  'copy': '__copy',
  'clear': '__clear',
  // dict
  'get': '__get',
  'items': '__items',
  'update': '__update',
  'setdefault': '__setdefault',
  // collections.deque
  'popleft': '__popleft',
  'appendleft': '__appendleft',
  'extendleft': '__extendleft',
  'rotate': '__rotate',
  // collections.Counter
  'most_common': '__most_common',
  // set
  'discard': '__discard',
  'union': '__union',
  'intersection': '__intersection',
  'difference': '__difference',
  // str
  'upper': '__upper',
  'lower': '__lower',
  'strip': '__strip',
  'lstrip': '__lstrip',
  'rstrip': '__rstrip',
  'startswith': '__startswith',
  'endswith': '__endswith',
  'replace': '__replace',
  'find': '__find',
  'split': '__split',
  'join': '__join',
  'rjust': '__rjust',
  'ljust': '__ljust',
  'isdigit': '__isdigit',
  'isalpha': '__isalpha',
  'isspace': '__isspace',
  'isupper': '__isupper',
  'islower': '__islower',
};

/// The globals a Python program starts with, layered over the engine's own
/// prelude so that where the two disagree — `min` of a whole list rather than
/// of two arguments — Python's meaning wins.
Map<String, Value> pythonGlobals() => <String, Value>{
      'len': const NativeFunctionValue('len', 1, _len),
      'range': const NativeFunctionValue('range', 3, _range),
      'sorted': const NativeFunctionValue('sorted', 3, _sorted),
      'sum': const NativeFunctionValue('sum', 2, _sum),
      'min': const NativeFunctionValue('min', 2, _min),
      'max': const NativeFunctionValue('max', 2, _max),
      'abs': const NativeFunctionValue('abs', 1, _abs),
      'round': const NativeFunctionValue('round', 2, _round),
      'enumerate': const NativeFunctionValue('enumerate', 2, _enumerate),
      'zip': const NativeFunctionValue('zip', 2, _zip),
      'reversed': const NativeFunctionValue('reversed', 1, _reversed),
      'any': const NativeFunctionValue('any', 1, _any),
      'all': const NativeFunctionValue('all', 1, _all),
      'map': const NativeFunctionValue('map', 2, _map),
      'filter': const NativeFunctionValue('filter', 2, _filter),
      'str': const NativeFunctionValue('str', 1, _str),
      'int': const NativeFunctionValue('int', 1, _int),
      'float': const NativeFunctionValue('float', 1, _float),
      'bool': const NativeFunctionValue('bool', 1, _bool),
      'list': const NativeFunctionValue('list', 1, _list),
      'tuple': const NativeFunctionValue('tuple', 1, _tuple),
      'set': const NativeFunctionValue('set', 1, _set),
      'dict': const NativeFunctionValue('dict', 1, _dict),
      'ord': const NativeFunctionValue('ord', 1, _ord),
      'chr': const NativeFunctionValue('chr', 1, _chr),
      'divmod': const NativeFunctionValue('divmod', 2, _divmod),

      // `collections` and `heapq`. Bound unconditionally rather than by the
      // import statement, which only validates the module name — see
      // `python_parser.dart`'s `_importStatement`.
      'deque': const NativeFunctionValue('deque', 1, pyDeque),
      'Counter': const NativeFunctionValue('Counter', 1, pyCounter),
      'defaultdict': const NativeFunctionValue('defaultdict', 1, pyDefaultDict),
      'heapq': pyHeapqNamespace(),
      'collections': pyCollectionsNamespace(),

      // Everything below is reached only from lowered syntax, never written
      // by a learner. Each one exists because the choice it makes — is this
      // a list or a dict? one separator or whitespace? — can only be made
      // once the value is in hand, at runtime.
      '__contains__': _method('__contains__', '__contains__', 2, _contains),
      '__append': _method('__append', 'append', 2, _append),
      '__extend': _method('__extend', 'extend', 2, _extend),
      '__insert': _method('__insert', 'insert', 3, _insert),
      '__union': _method('__union', 'union', 2, _union),
      '__intersection': _method('__intersection', 'intersection', 2, _intersection),
      '__difference': _method('__difference', 'difference', 2, _difference),
      '__upper': _method('__upper', 'upper', 1, (a, i) => _mapString(a[0], (s) => s.toUpperCase())),
      '__lower': _method('__lower', 'lower', 1, (a, i) => _mapString(a[0], (s) => s.toLowerCase())),
      '__strip': _method('__strip', 'strip', 1, (a, i) => _mapString(a[0], (s) => s.trim())),
      '__lstrip': _method('__lstrip', 'lstrip', 1, (a, i) => _mapString(a[0], (s) => s.trimLeft())),
      '__rstrip': _method('__rstrip', 'rstrip', 1, (a, i) => _mapString(a[0], (s) => s.trimRight())),
      '__startswith':
          _method('__startswith', 'startswith', 2, (a, i) => BoolValue(_str2(a[0]).startsWith(_str2(a[1])))),
      '__endswith':
          _method('__endswith', 'endswith', 2, (a, i) => BoolValue(_str2(a[0]).endsWith(_str2(a[1])))),
      '__replace': _method(
          '__replace', 'replace', 3, (a, i) => StrValue(_str2(a[0]).replaceAll(_str2(a[1]), _str2(a[2])))),
      '__rjust': _method('__rjust', 'rjust', 3, (a, i) => _pad(a, left: true)),
      '__ljust': _method('__ljust', 'ljust', 3, (a, i) => _pad(a, left: false)),
      '__pop': _method('__pop', 'pop', 3, _pop),
      '__remove': _method('__remove', 'remove', 2, _remove),
      '__popleft': _method('__popleft', 'popleft', 1, pyPopLeft),
      '__appendleft': _method('__appendleft', 'appendleft', 2, pyAppendLeft),
      '__extendleft': _method('__extendleft', 'extendleft', 2, pyExtendLeft),
      '__rotate': _method('__rotate', 'rotate', 2, pyRotate),
      '__most_common': _method('__most_common', 'most_common', 2, pyMostCommon),
      '__discard': _method('__discard', 'discard', 2, _discard),
      '__count': _method('__count', 'count', 2, _count),
      '__index_of': _method('__index_of', 'index', 2, _indexOf),
      '__find': _method('__find', 'find', 2, _find),
      '__sort': _method('__sort', 'sort', 3, _sortInPlace),
      '__reverse': _method('__reverse', 'reverse', 1, _reverseInPlace),
      '__copy': _method('__copy', 'copy', 1, _copy),
      '__clear': _method('__clear', 'clear', 1, _clear),
      '__get': _method('__get', 'get', 3, _get),
      '__items': _method('__items', 'items', 1, _items),
      '__update': _method('__update', 'update', 2, _update),
      '__setdefault': _method('__setdefault', 'setdefault', 3, _setdefault),
      '__split': _method('__split', 'split', 2, _split),
      '__join': _method('__join', 'join', 2, _join),
      '__isdigit': _method('__isdigit', 'isdigit', 1, _isdigit),
      '__isalpha': _method('__isalpha', 'isalpha', 1, _isalpha),
      '__isspace': _method('__isspace', 'isspace', 1, _isspace),
      '__isupper': _method('__isupper', 'isupper', 1, _isupper),
      '__islower': _method('__islower', 'islower', 1, _islower),
    };

/// Wraps one method helper so that a learner's own method of the same name
/// always wins over the builtin. See [_userDefined].
NativeFunctionValue _method(String globalName, String pythonName, int arity,
    Value Function(List<Value> args, InvokeCallback invoke) builtin) {
  return NativeFunctionValue(globalName, arity, (args, invoke) {
    final own = _userDefined(args[0], pythonName, args.sublist(1), invoke);
    return own ?? builtin(args, invoke);
  });
}

/// Parameter names of the builtins that accept keyword arguments, so the
/// parser can turn `sorted(xs, reverse=True)` into a positional call.
const Map<String, List<String>> pythonBuiltinParams = <String, List<String>>{
  'sorted': <String>['iterable', 'key', 'reverse'],
  'sum': <String>['iterable', 'start'],
  'enumerate': <String>['iterable', 'start'],
  'round': <String>['number', 'ndigits'],
};

// ---------------------------------------------------------------------------

List<Value> _iter(Value v) {
  if (v is ListValue) return v.items;
  if (v is TupleValue) return v.items;
  if (v is SetValue) return v.items.toList();
  if (v is MapValue) return v.entries.keys.toList();
  if (v is StrValue) return <Value>[for (final c in v.value.split('')) StrValue(c)];
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'an iterable'});
}

double _num(Value v) {
  if (v is IntValue) return v.value.toDouble();
  if (v is NumValue) return v.value;
  if (v is BoolValue) return v.value ? 1 : 0;
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a number'});
}

int _intArg(Value v) {
  if (v is IntValue) return v.value;
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'an integer'});
}

bool _truthy(Value v) => isTruthy(v, pythonDialect);

Value _len(List<Value> args, InvokeCallback invoke) {
  final v = args[0];
  if (v is StrValue) return IntValue(v.value.length);
  if (v is MapValue) return IntValue(v.entries.length);
  if (v is SetValue) return IntValue(v.items.length);
  return IntValue(_iter(v).length);
}

Value _range(List<Value> args, InvokeCallback invoke) {
  final int start;
  final int stop;
  final int step;
  if (args.length == 1) {
    start = 0;
    stop = _intArg(args[0]);
    step = 1;
  } else {
    start = _intArg(args[0]);
    stop = _intArg(args[1]);
    step = args.length > 2 ? _intArg(args[2]) : 1;
  }
  if (step == 0) {
    throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a non-zero range step'});
  }
  // Materialised rather than lazy: the engine has no iterator protocol, and
  // the execution budget already caps a run that asks for an absurd range.
  final out = <Value>[];
  for (var i = start; step > 0 ? i < stop : i > stop; i += step) {
    out.add(IntValue(i));
  }
  return ListValue(out);
}

Value _sorted(List<Value> args, InvokeCallback invoke) {
  final items = List<Value>.of(_iter(args[0]));
  final key = args.length > 1 && args[1] is FunctionValue ? args[1] as FunctionValue : null;
  final reverse = args.length > 2 && _truthy(args[2]);
  if (key == null) {
    items.sort((a, b) => compareValues(a, b, pythonDialect));
  } else {
    // Decorate-sort-undecorate, so the key function runs once per element
    // rather than once per comparison.
    final decorated = <(Value, Value)>[
      for (final e in items) (invoke(key, <Value>[e]), e)
    ];
    decorated.sort((a, b) => compareValues(a.$1, b.$1, pythonDialect));
    items
      ..clear()
      ..addAll(decorated.map((d) => d.$2));
  }
  if (reverse) return ListValue(items.reversed.toList());
  return ListValue(items);
}

Value _sum(List<Value> args, InvokeCallback invoke) {
  final items = _iter(args[0]);
  var acc = args.length > 1 ? args[1] : const IntValue(0);
  for (final e in items) {
    if (acc is IntValue && e is IntValue) {
      acc = IntValue(acc.value + e.value);
    } else {
      acc = NumValue(_num(acc) + _num(e));
    }
  }
  return acc;
}

/// `min(xs)` over one iterable, or `min(a, b, ...)` over the arguments —
/// Python spells both the same way.
List<Value> _candidates(List<Value> args) {
  if (args.length == 1) return _iter(args[0]);
  return args;
}

Value _min(List<Value> args, InvokeCallback invoke) {
  final xs = _candidates(args);
  if (xs.isEmpty) {
    throw const VmRuntimeError('runtime', <String, Object?>{'message': 'min of an empty sequence'});
  }
  return xs.reduce((a, b) => compareValues(b, a, pythonDialect) < 0 ? b : a);
}

Value _max(List<Value> args, InvokeCallback invoke) {
  final xs = _candidates(args);
  if (xs.isEmpty) {
    throw const VmRuntimeError('runtime', <String, Object?>{'message': 'max of an empty sequence'});
  }
  return xs.reduce((a, b) => compareValues(b, a, pythonDialect) > 0 ? b : a);
}

Value _abs(List<Value> args, InvokeCallback invoke) {
  final v = args[0];
  if (v is IntValue) return IntValue(v.value.abs());
  return NumValue(_num(v).abs());
}

Value _round(List<Value> args, InvokeCallback invoke) {
  final x = _num(args[0]);
  if (args.length < 2) return IntValue(x.round());
  final digits = _intArg(args[1]);
  final factor = <double>[1, 10, 100, 1000, 10000].elementAtOrNull(digits) ?? 1.0;
  return NumValue((x * factor).round() / factor);
}

Value _enumerate(List<Value> args, InvokeCallback invoke) {
  final items = _iter(args[0]);
  final start = args.length > 1 ? _intArg(args[1]) : 0;
  return ListValue(<Value>[
    for (var i = 0; i < items.length; i++) TupleValue(<Value>[IntValue(start + i), items[i]]),
  ]);
}

Value _zip(List<Value> args, InvokeCallback invoke) {
  final lists = <List<Value>>[for (final a in args) _iter(a)];
  if (lists.isEmpty) return ListValue(<Value>[]);
  final shortest = lists.map((l) => l.length).reduce((a, b) => a < b ? a : b);
  return ListValue(<Value>[
    for (var i = 0; i < shortest; i++) TupleValue(<Value>[for (final l in lists) l[i]]),
  ]);
}

Value _reversed(List<Value> args, InvokeCallback invoke) => ListValue(_iter(args[0]).reversed.toList());

Value _any(List<Value> args, InvokeCallback invoke) => BoolValue(_iter(args[0]).any(_truthy));

Value _all(List<Value> args, InvokeCallback invoke) => BoolValue(_iter(args[0]).every(_truthy));

Value _map(List<Value> args, InvokeCallback invoke) {
  final f = args[0] as FunctionValue;
  return ListValue(<Value>[
    for (final e in _iter(args[1])) invoke(f, <Value>[e])
  ]);
}

Value _filter(List<Value> args, InvokeCallback invoke) {
  final f = args[0] as FunctionValue;
  return ListValue(<Value>[
    for (final e in _iter(args[1]))
      if (_truthy(invoke(f, <Value>[e]))) e,
  ]);
}

Value _str(List<Value> args, InvokeCallback invoke) => StrValue(displayString(args[0], pythonDialect));

Value _int(List<Value> args, InvokeCallback invoke) {
  final v = args[0];
  if (v is IntValue) return v;
  if (v is BoolValue) return IntValue(v.value ? 1 : 0);
  if (v is NumValue) return IntValue(v.value.truncate());
  if (v is StrValue) {
    final parsed = int.tryParse(v.value.trim());
    if (parsed == null) {
      throw VmRuntimeError(
          'typeMismatch', <String, Object?>{'expected': 'an integer string', 'actual': v.value});
    }
    return IntValue(parsed);
  }
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a number or string'});
}

Value _float(List<Value> args, InvokeCallback invoke) {
  final v = args[0];
  if (v is StrValue) {
    // `float('inf')` is how Python spells "no bound yet", and shortest-path
    // and minimum-tracking solutions lean on it heavily.
    final text = v.value.trim().toLowerCase();
    if (text == 'inf' || text == '+inf' || text == 'infinity') return const NumValue(double.infinity);
    if (text == '-inf' || text == '-infinity') return const NumValue(double.negativeInfinity);
    if (text == 'nan') return const NumValue(double.nan);
    final parsed = double.tryParse(v.value.trim());
    if (parsed == null) {
      throw VmRuntimeError(
          'typeMismatch', <String, Object?>{'expected': 'a number string', 'actual': v.value});
    }
    return NumValue(parsed);
  }
  return NumValue(_num(v));
}

Value _bool(List<Value> args, InvokeCallback invoke) => BoolValue(_truthy(args[0]));

Value _list(List<Value> args, InvokeCallback invoke) =>
    ListValue(args.isEmpty ? <Value>[] : List<Value>.of(_iter(args[0])));

Value _tuple(List<Value> args, InvokeCallback invoke) =>
    TupleValue(args.isEmpty ? <Value>[] : List<Value>.of(_iter(args[0])));

Value _set(List<Value> args, InvokeCallback invoke) =>
    SetValue(LinkedHashSet<Value>.of(args.isEmpty ? <Value>[] : _iter(args[0])));

Value _dict(List<Value> args, InvokeCallback invoke) {
  final map = MapValue();
  if (args.isEmpty) return map;
  final source = args[0];
  if (source is MapValue) {
    map.entries.addAll(source.entries);
    return map;
  }
  // dict([(k, v), ...])
  for (final pair in _iter(source)) {
    final kv = _iter(pair);
    if (kv.length != 2) {
      throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a key/value pair'});
    }
    map.entries[kv[0]] = kv[1];
  }
  return map;
}

Value _ord(List<Value> args, InvokeCallback invoke) {
  final s = args[0];
  if (s is! StrValue || s.value.length != 1) {
    throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a one-character string'});
  }
  return IntValue(s.value.codeUnitAt(0));
}

Value _chr(List<Value> args, InvokeCallback invoke) => StrValue(String.fromCharCode(_intArg(args[0])));

Value _divmod(List<Value> args, InvokeCallback invoke) {
  final a = _intArg(args[0]);
  final b = _intArg(args[1]);
  if (b == 0) throw const VmRuntimeError('divisionByZero');
  return TupleValue(<Value>[IntValue((a / b).floor()), IntValue(a - (a / b).floor() * b)]);
}

// ---------------------------------------------------------------------------
// Method helpers. Each takes the receiver first.
// ---------------------------------------------------------------------------

/// Hands a helper call back to the learner's own method when the receiver
/// turns out to be one of their objects.
///
/// The parser rewrites `x.pop()` into `__pop(x)` without knowing what `x`
/// is — it cannot, since the same spelling means different things for a list
/// and for a dict. But a learner writing `class Stack` with a `pop` method
/// would otherwise have their call stolen by the builtin, which is both
/// wrong and baffling. So every helper checks first: if the receiver is an
/// instance with a method of that name, that method wins.
Value? _userDefined(Value receiver, String name, List<Value> args, InvokeCallback invoke) {
  if (receiver is! InstanceValue) return null;
  final method = receiver.klass.findMethod(name);
  if (method == null) return null;
  return invoke(method.bindTo(receiver), args);
}

String _str2(Value v) {
  if (v is StrValue) return v.value;
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a string'});
}

Value _mapString(Value v, String Function(String) f) => StrValue(f(_str2(v)));

ListValue _listArg(Value v) {
  if (v is ListValue) return v;
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a list'});
}

SetValue _setArg(Value v) {
  if (v is SetValue) return v;
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a set'});
}

Value _append(List<Value> args, InvokeCallback invoke) {
  _listArg(args[0]).items.add(args[1]);
  return NullValue.instance;
}

Value _extend(List<Value> args, InvokeCallback invoke) {
  _listArg(args[0]).items.addAll(_iter(args[1]));
  return NullValue.instance;
}

Value _insert(List<Value> args, InvokeCallback invoke) {
  final items = _listArg(args[0]).items;
  var i = _intArg(args[1]);
  if (i < 0) i += items.length;
  items.insert(i.clamp(0, items.length), args[2]);
  return NullValue.instance;
}

Value _union(List<Value> args, InvokeCallback invoke) =>
    SetValue(LinkedHashSet<Value>.of(_setArg(args[0]).items)..addAll(_iter(args[1])));

Value _intersection(List<Value> args, InvokeCallback invoke) {
  final other = _iter(args[1]).toSet();
  return SetValue(LinkedHashSet<Value>.of(_setArg(args[0]).items.where(other.contains)));
}

Value _difference(List<Value> args, InvokeCallback invoke) {
  final other = _iter(args[1]).toSet();
  return SetValue(LinkedHashSet<Value>.of(_setArg(args[0]).items.where((e) => !other.contains(e))));
}

Value _pad(List<Value> args, {required bool left}) {
  final s = _str2(args[0]);
  final width = _intArg(args[1]);
  final fill = args.length > 2 && args[2] is StrValue ? (args[2] as StrValue).value : ' ';
  return StrValue(left ? s.padLeft(width, fill) : s.padRight(width, fill));
}

/// `xs.pop()` / `xs.pop(i)` / `d.pop(k)` / `d.pop(k, default)`.
Value _pop(List<Value> args, InvokeCallback invoke) {
  final receiver = args[0];
  if (receiver is MapValue) {
    if (args.length < 2) {
      throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a key to pop'});
    }
    final removed = receiver.entries.remove(args[1]);
    if (removed != null) return removed;
    if (args.length > 2) return args[2];
    throw VmRuntimeError('keyNotFound', <String, Object?>{'key': displayString(args[1], pythonDialect)});
  }
  if (receiver is ListValue) {
    if (receiver.items.isEmpty) {
      throw const VmRuntimeError('indexOutOfRange', <String, Object?>{'index': -1, 'length': 0});
    }
    if (args.length < 2) return receiver.items.removeLast();
    var i = _intArg(args[1]);
    if (i < 0) i += receiver.items.length;
    if (i < 0 || i >= receiver.items.length) {
      throw VmRuntimeError(
          'indexOutOfRange', <String, Object?>{'index': _intArg(args[1]), 'length': receiver.items.length});
    }
    return receiver.items.removeAt(i);
  }
  if (receiver is SetValue) {
    if (receiver.items.isEmpty) {
      throw const VmRuntimeError('runtime', <String, Object?>{'message': 'pop from an empty set'});
    }
    final first = receiver.items.first;
    receiver.items.remove(first);
    return first;
  }
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a list, dict or set'});
}

/// Python's `remove` raises when the item is absent, unlike `discard`.
Value _remove(List<Value> args, InvokeCallback invoke) {
  final receiver = args[0];
  final target = args[1];
  final removed = switch (receiver) {
    ListValue() => receiver.items.remove(target),
    SetValue() => receiver.items.remove(target),
    MapValue() => receiver.entries.remove(target) != null,
    _ => throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a list, dict or set'}),
  };
  if (!removed) {
    throw VmRuntimeError('runtime',
        <String, Object?>{'message': '${displayString(target, pythonDialect)} is not in the collection'});
  }
  return NullValue.instance;
}

Value _discard(List<Value> args, InvokeCallback invoke) {
  final receiver = args[0];
  if (receiver is SetValue) receiver.items.remove(args[1]);
  return NullValue.instance;
}

Value _count(List<Value> args, InvokeCallback invoke) {
  final receiver = args[0];
  final target = args[1];
  if (receiver is StrValue) {
    final needle = (target as StrValue).value;
    if (needle.isEmpty) return IntValue(receiver.value.length + 1);
    // Non-overlapping, as Python counts.
    var count = 0;
    var from = 0;
    while (true) {
      final at = receiver.value.indexOf(needle, from);
      if (at < 0) break;
      count++;
      from = at + needle.length;
    }
    return IntValue(count);
  }
  return IntValue(_iter(receiver).where((e) => e == target).length);
}

/// Python's `index` raises when absent; `find` returns -1. Both are here.
Value _indexOf(List<Value> args, InvokeCallback invoke) {
  final at = _findIndex(args[0], args[1]);
  if (at < 0) {
    throw VmRuntimeError('runtime',
        <String, Object?>{'message': '${displayString(args[1], pythonDialect)} is not in the collection'});
  }
  return IntValue(at);
}

Value _find(List<Value> args, InvokeCallback invoke) => IntValue(_findIndex(args[0], args[1]));

int _findIndex(Value receiver, Value target) {
  if (receiver is StrValue) {
    if (target is! StrValue) {
      throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a string'});
    }
    return receiver.value.indexOf(target.value);
  }
  return _iter(receiver).indexOf(target);
}

/// `xs.sort()`, `xs.sort(key=f)`, `xs.sort(reverse=True)` — in place, and
/// returning `None`, exactly as Python does.
Value _sortInPlace(List<Value> args, InvokeCallback invoke) {
  final receiver = args[0];
  if (receiver is! ListValue) {
    throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a list'});
  }
  final sorted =
      _sorted(<Value>[receiver, if (args.length > 1) args[1], if (args.length > 2) args[2]], invoke);
  receiver.items
    ..clear()
    ..addAll((sorted as ListValue).items);
  return NullValue.instance;
}

Value _reverseInPlace(List<Value> args, InvokeCallback invoke) {
  final receiver = args[0];
  if (receiver is! ListValue) {
    throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a list'});
  }
  final reversed = receiver.items.reversed.toList();
  receiver.items
    ..clear()
    ..addAll(reversed);
  return NullValue.instance;
}

Value _copy(List<Value> args, InvokeCallback invoke) {
  final receiver = args[0];
  if (receiver is ListValue) return ListValue(List<Value>.of(receiver.items));
  if (receiver is SetValue) return SetValue(LinkedHashSet<Value>.of(receiver.items));
  if (receiver is MapValue) return MapValue()..entries.addAll(receiver.entries);
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a list, dict or set'});
}

Value _clear(List<Value> args, InvokeCallback invoke) {
  final receiver = args[0];
  if (receiver is ListValue) {
    receiver.items.clear();
  } else if (receiver is SetValue) {
    receiver.items.clear();
  } else if (receiver is MapValue) {
    receiver.entries.clear();
  } else {
    throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a list, dict or set'});
  }
  return NullValue.instance;
}

/// `d.get(k)` is `None` when absent, `d.get(k, fallback)` is the fallback —
/// never an error, which is what separates it from `d[k]`.
Value _get(List<Value> args, InvokeCallback invoke) {
  final receiver = args[0];
  if (receiver is! MapValue) {
    throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a dict'});
  }
  final found = receiver.entries[args[1]];
  if (found != null) return found;
  return args.length > 2 ? args[2] : NullValue.instance;
}

Value _items(List<Value> args, InvokeCallback invoke) {
  final receiver = args[0];
  if (receiver is! MapValue) {
    throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a dict'});
  }
  return ListValue(<Value>[
    for (final e in receiver.entries.entries) TupleValue(<Value>[e.key, e.value]),
  ]);
}

Value _update(List<Value> args, InvokeCallback invoke) {
  final receiver = args[0];
  if (receiver is MapValue) {
    final other = args[1];
    if (other is! MapValue) {
      throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a dict'});
    }
    receiver.entries.addAll(other.entries);
    return NullValue.instance;
  }
  if (receiver is SetValue) {
    receiver.items.addAll(_iter(args[1]));
    return NullValue.instance;
  }
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a dict or set'});
}

Value _setdefault(List<Value> args, InvokeCallback invoke) {
  final receiver = args[0];
  if (receiver is! MapValue) {
    throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a dict'});
  }
  final existing = receiver.entries[args[1]];
  if (existing != null) return existing;
  final fallback = args.length > 2 ? args[2] : NullValue.instance;
  receiver.entries[args[1]] = fallback;
  return fallback;
}

/// `s.split()` with no separator splits on runs of whitespace and drops empty
/// pieces; `s.split(sep)` keeps them. Python really does treat the two cases
/// differently.
Value _split(List<Value> args, InvokeCallback invoke) {
  final receiver = args[0];
  if (receiver is! StrValue) {
    throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a string'});
  }
  if (args.length < 2 || args[1] is NullValue) {
    final pieces = receiver.value.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return ListValue(<Value>[for (final p in pieces) StrValue(p)]);
  }
  final sep = (args[1] as StrValue).value;
  return ListValue(<Value>[for (final p in receiver.value.split(sep)) StrValue(p)]);
}

/// `sep.join(xs)` — the receiver is the separator, which is the other way
/// round from every other language here.
Value _join(List<Value> args, InvokeCallback invoke) {
  final sep = args[0];
  if (sep is! StrValue) {
    throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a string separator'});
  }
  return StrValue(_iter(args[1]).map((e) => displayString(e, pythonDialect)).join(sep.value));
}

Value _charTest(Value v, bool Function(String) test) {
  if (v is! StrValue) {
    throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a string'});
  }
  if (v.value.isEmpty) return const BoolValue(false);
  return BoolValue(v.value.split('').every(test));
}

Value _isdigit(List<Value> args, InvokeCallback invoke) =>
    _charTest(args[0], (c) => c.codeUnitAt(0) >= 0x30 && c.codeUnitAt(0) <= 0x39);

Value _isalpha(List<Value> args, InvokeCallback invoke) => _charTest(args[0], (c) {
      final u = c.codeUnitAt(0);
      return (u >= 0x41 && u <= 0x5A) || (u >= 0x61 && u <= 0x7A);
    });

Value _isspace(List<Value> args, InvokeCallback invoke) => _charTest(args[0], (c) => c.trim().isEmpty);

Value _isupper(List<Value> args, InvokeCallback invoke) =>
    _charTest(args[0], (c) => c.toUpperCase() == c && c.toLowerCase() != c);

Value _islower(List<Value> args, InvokeCallback invoke) =>
    _charTest(args[0], (c) => c.toLowerCase() == c && c.toUpperCase() != c);

Value _contains(List<Value> args, InvokeCallback invoke) {
  final container = args[0];
  final item = args[1];
  if (container is MapValue) return BoolValue(container.entries.containsKey(item));
  if (container is SetValue) return BoolValue(container.items.contains(item));
  if (container is StrValue) {
    if (item is! StrValue) {
      throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a string'});
    }
    return BoolValue(container.value.contains(item.value));
  }
  return BoolValue(_iter(container).contains(item));
}
