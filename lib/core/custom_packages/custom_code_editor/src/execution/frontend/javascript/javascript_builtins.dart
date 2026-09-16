/// JavaScript's builtins and method surface, expressed on top of the shared
/// value model.
///
/// Like the Python frontend's equivalent, everything here is built out of
/// public `Value` types so that nothing in `vm/` or `stdlib/` has to know
/// JavaScript exists (contract obligation O5, FR-031).
///
/// JavaScript needs its own implementations rather than renames onto the
/// shared stdlib for one specific reason: **callback arity**. `arr.map(fn)`
/// calls `fn(element, index, array)` in JavaScript, and a learner who writes
/// `arr.map(x => x * 2)` declares only one parameter. Passing three arguments
/// to a one-parameter function is an error in this engine but perfectly
/// ordinary in JavaScript, so every callback here is called with exactly as
/// many arguments as it declares — see [_callback].
library;

import 'dart:collection';
import 'dart:math' as math;

import '../../errors/failure.dart';
import '../../values/value.dart';
import 'javascript_dialect.dart';

/// JavaScript methods the frontend translates, mapped to the helper global
/// that implements it. The helper takes the receiver as its first argument.
///
/// A method that is not listed is left as the learner wrote it, so their own
/// class methods reach their own class.
const Map<String, String> jsMethodHelpers = <String, String>{
  // array
  'push': '__push',
  'pop': '__pop',
  'shift': '__shift',
  'unshift': '__unshift',
  'slice': '__slice',
  'splice': '__splice',
  'concat': '__concat',
  'join': '__join',
  'reverse': '__reverse',
  'sort': '__sort',
  'map': '__map',
  'filter': '__filter',
  'reduce': '__reduce',
  'forEach': '__forEach',
  'find': '__find',
  'findIndex': '__findIndex',
  'some': '__some',
  'every': '__every',
  'flat': '__flat',
  'fill': '__fill',
  // shared between array and string
  'indexOf': '__indexOf',
  'lastIndexOf': '__lastIndexOf',
  'includes': '__includes',
  'at': '__at',
  // string
  'charAt': '__charAt',
  'charCodeAt': '__charCodeAt',
  'substring': '__substring',
  'split': '__split',
  'toUpperCase': '__toUpperCase',
  'toLowerCase': '__toLowerCase',
  'trim': '__trim',
  'replace': '__replace',
  'replaceAll': '__replaceAll',
  'startsWith': '__startsWith',
  'endsWith': '__endsWith',
  'repeat': '__repeat',
  'padStart': '__padStart',
  'padEnd': '__padEnd',
  // Map and Set
  'get': '__mapGet',
  'set': '__mapSet',
  'has': '__has',
  'delete': '__delete',
  'add': '__add',
  'keys': '__keysOf',
  'values': '__valuesOf',
  'entries': '__entriesOf',
  // number
  'toFixed': '__toFixed',
  'toString': '__toString',
};

/// Properties the frontend translates. `.size` has no shared counterpart and
/// `.length` on a Map means nothing in JavaScript, so both are routed to a
/// helper that decides with the value in hand.
const Map<String, String> jsPropertyHelpers = <String, String>{'size': '__size'};

Map<String, Value> javascriptGlobals() => <String, Value>{
      'console': const NamespaceValue('console', <String, Value>{
        'log': NativeFunctionValue('console.log', 1, _identityFirst),
      }),
      'Math': const NamespaceValue('Math', <String, Value>{
        'abs': NativeFunctionValue('Math.abs', 1, _abs),
        'floor': NativeFunctionValue('Math.floor', 1, _floor),
        'ceil': NativeFunctionValue('Math.ceil', 1, _ceil),
        'round': NativeFunctionValue('Math.round', 1, _round),
        'trunc': NativeFunctionValue('Math.trunc', 1, _trunc),
        'sqrt': NativeFunctionValue('Math.sqrt', 1, _sqrt),
        'pow': NativeFunctionValue('Math.pow', 2, _pow),
        'min': NativeFunctionValue('Math.min', 2, _mathMin),
        'max': NativeFunctionValue('Math.max', 2, _mathMax),
        'sign': NativeFunctionValue('Math.sign', 1, _sign),
        'Infinity': NumValue(double.infinity),
      }),
      'Object': const NamespaceValue('Object', <String, Value>{
        'keys': NativeFunctionValue('Object.keys', 1, _objectKeys),
        'values': NativeFunctionValue('Object.values', 1, _objectValues),
        'entries': NativeFunctionValue('Object.entries', 1, _objectEntries),
        'freeze': NativeFunctionValue('Object.freeze', 1, _identityFirst),
        'assign': NativeFunctionValue('Object.assign', 2, _objectAssign),
      }),
      'Array': const NamespaceValue('Array', <String, Value>{
        'isArray': NativeFunctionValue('Array.isArray', 1, _isArray),
        'from': NativeFunctionValue('Array.from', 2, _arrayFrom),
        'of': NativeFunctionValue('Array.of', 1, _arrayOf),
      }),
      'Number': const NamespaceValue('Number', <String, Value>{
        'isInteger': NativeFunctionValue('Number.isInteger', 1, _isInteger),
        'isNaN': NativeFunctionValue('Number.isNaN', 1, _isNan),
        'parseInt': NativeFunctionValue('Number.parseInt', 2, _parseInt),
        'parseFloat': NativeFunctionValue('Number.parseFloat', 1, _parseFloat),
        'MAX_SAFE_INTEGER': IntValue(9007199254740991),
        'MIN_SAFE_INTEGER': IntValue(-9007199254740991),
        'POSITIVE_INFINITY': NumValue(double.infinity),
        'NEGATIVE_INFINITY': NumValue(double.negativeInfinity),
      }),
      'String': const NamespaceValue('String', <String, Value>{
        'fromCharCode': NativeFunctionValue('String.fromCharCode', 1, _fromCharCode),
      }),
      'parseInt': const NativeFunctionValue('parseInt', 2, _parseInt),
      'parseFloat': const NativeFunctionValue('parseFloat', 1, _parseFloat),
      'isNaN': const NativeFunctionValue('isNaN', 1, _isNan),
      'Infinity': const NumValue(double.infinity),
      'NaN': const NumValue(double.nan),
      'undefined': UndefinedValue.instance,

      // Reached only from lowered syntax.
      '__looseEq': const NativeFunctionValue('__looseEq', 2, _looseEq),
      '__typeof': const NativeFunctionValue('__typeof', 1, _typeOf),
      '__newMap': const NativeFunctionValue('__newMap', 1, _newMap),
      '__newSet': const NativeFunctionValue('__newSet', 1, _newSet),
      '__newArray': const NativeFunctionValue('__newArray', 1, _newArray),

      '__size': _method('__size', 'size', 1, _size),
      '__push': _method('__push', 'push', 2, _push),
      '__pop': _method('__pop', 'pop', 1, _pop),
      '__shift': _method('__shift', 'shift', 1, _shift),
      '__unshift': _method('__unshift', 'unshift', 2, _unshift),
      '__slice': _method('__slice', 'slice', 3, _slice),
      '__splice': _method('__splice', 'splice', 3, _splice),
      '__concat': _method('__concat', 'concat', 2, _concat),
      '__join': _method('__join', 'join', 2, _join),
      '__reverse': _method('__reverse', 'reverse', 1, _reverse),
      '__sort': _method('__sort', 'sort', 2, _sort),
      '__map': _method('__map', 'map', 2, _map),
      '__filter': _method('__filter', 'filter', 2, _filter),
      '__reduce': _method('__reduce', 'reduce', 3, _reduce),
      '__forEach': _method('__forEach', 'forEach', 2, _forEach),
      '__find': _method('__find', 'find', 2, _find),
      '__findIndex': _method('__findIndex', 'findIndex', 2, _findIndex),
      '__some': _method('__some', 'some', 2, _some),
      '__every': _method('__every', 'every', 2, _every),
      '__flat': _method('__flat', 'flat', 2, _flat),
      '__fill': _method('__fill', 'fill', 2, _fill),
      '__indexOf': _method('__indexOf', 'indexOf', 2, _indexOf),
      '__lastIndexOf': _method('__lastIndexOf', 'lastIndexOf', 2, _lastIndexOf),
      '__includes': _method('__includes', 'includes', 2, _includes),
      '__at': _method('__at', 'at', 2, _at),
      '__charAt': _method('__charAt', 'charAt', 2, _charAt),
      '__charCodeAt': _method('__charCodeAt', 'charCodeAt', 2, _charCodeAt),
      '__substring': _method('__substring', 'substring', 3, _substring),
      '__split': _method('__split', 'split', 2, _split),
      '__toUpperCase':
          _method('__toUpperCase', 'toUpperCase', 1, (a, i) => StrValue(_str(a[0]).toUpperCase())),
      '__toLowerCase':
          _method('__toLowerCase', 'toLowerCase', 1, (a, i) => StrValue(_str(a[0]).toLowerCase())),
      '__trim': _method('__trim', 'trim', 1, (a, i) => StrValue(_str(a[0]).trim())),
      '__replace': _method('__replace', 'replace', 3, _replaceFirst),
      '__replaceAll': _method('__replaceAll', 'replaceAll', 3, _replaceAll),
      '__startsWith':
          _method('__startsWith', 'startsWith', 2, (a, i) => BoolValue(_str(a[0]).startsWith(_str(a[1])))),
      '__endsWith':
          _method('__endsWith', 'endsWith', 2, (a, i) => BoolValue(_str(a[0]).endsWith(_str(a[1])))),
      '__repeat': _method('__repeat', 'repeat', 2, (a, i) => StrValue(_str(a[0]) * _int(a[1]))),
      '__padStart': _method('__padStart', 'padStart', 3, (a, i) => _pad(a, start: true)),
      '__padEnd': _method('__padEnd', 'padEnd', 3, (a, i) => _pad(a, start: false)),
      '__mapGet': _method('__mapGet', 'get', 2, _mapGet),
      '__mapSet': _method('__mapSet', 'set', 3, _mapSet),
      '__has': _method('__has', 'has', 2, _has),
      '__delete': _method('__delete', 'delete', 2, _delete),
      '__add': _method('__add', 'add', 2, _add),
      '__keysOf': _method('__keysOf', 'keys', 1, _keysOf),
      '__valuesOf': _method('__valuesOf', 'values', 1, _valuesOf),
      '__entriesOf': _method('__entriesOf', 'entries', 1, _entriesOf),
      '__toFixed': _method('__toFixed', 'toFixed', 2, _toFixed),
      '__toString': _method('__toString', 'toString', 1, (a, i) => StrValue(_display(a[0]))),
    };

// ---------------------------------------------------------------------------

/// Hands a helper call back to the learner's own method when the receiver
/// turns out to be one of their objects — so `class Stack { pop() {...} }`
/// keeps its own `pop` instead of being stolen by the array builtin.
Value? _userDefined(Value receiver, String name, List<Value> args, InvokeCallback invoke) {
  if (receiver is! InstanceValue) return null;
  final field = receiver.fields[name];
  if (field is FunctionValue) return invoke(field, args);
  if (field != null && args.isEmpty) return field;
  final method = receiver.klass.findMethod(name);
  if (method == null) return null;
  return invoke(method.bindTo(receiver), args);
}

NativeFunctionValue _method(String globalName, String jsName, int arity,
    Value Function(List<Value> args, InvokeCallback invoke) builtin) {
  return NativeFunctionValue(globalName, arity, (args, invoke) {
    final own = _userDefined(args[0], jsName, args.sublist(1), invoke);
    return own ?? builtin(args, invoke);
  });
}

/// Calls a learner's callback with exactly the number of arguments it
/// declares, padding with `undefined` — JavaScript neither complains about
/// extra arguments nor about missing ones.
Value _callback(Value fn, List<Value> available, InvokeCallback invoke) {
  if (fn is! FunctionValue) {
    throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a function'});
  }
  final args = <Value>[
    for (var i = 0; i < fn.arity; i++) i < available.length ? available[i] : UndefinedValue.instance,
  ];
  return invoke(fn, args);
}

String _display(Value v) => displayString(v, javascriptDialect);
bool _truthy(Value v) => isTruthy(v, javascriptDialect);

String _str(Value v) {
  if (v is StrValue) return v.value;
  return _display(v);
}

int _int(Value v) {
  if (v is IntValue) return v.value;
  if (v is NumValue) return v.value.truncate();
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a number'});
}

double _num(Value v) {
  if (v is IntValue) return v.value.toDouble();
  if (v is NumValue) return v.value;
  if (v is BoolValue) return v.value ? 1 : 0;
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a number'});
}

/// A whole result stays whole, so `4 / 2` is `2` rather than `2.0`.
Value _number(double d) {
  if (d.isFinite && d == d.roundToDouble() && d.abs() < 9007199254740992.0) return IntValue(d.toInt());
  return NumValue(d);
}

ListValue _array(Value v) {
  if (v is ListValue) return v;
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'an array'});
}

List<Value> _iter(Value v) {
  if (v is ListValue) return v.items;
  if (v is TupleValue) return v.items;
  if (v is SetValue) return v.items.toList();
  if (v is MapValue) return v.entries.keys.toList();
  if (v is StrValue) return <Value>[for (final c in v.value.split('')) StrValue(c)];
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'an iterable'});
}

Value _identityFirst(List<Value> args, InvokeCallback invoke) =>
    args.isEmpty ? UndefinedValue.instance : args[0];

// --- Math ------------------------------------------------------------------

Value _abs(List<Value> a, InvokeCallback i) => _number(_num(a[0]).abs());
Value _floor(List<Value> a, InvokeCallback i) => IntValue(_num(a[0]).floor());
Value _ceil(List<Value> a, InvokeCallback i) => IntValue(_num(a[0]).ceil());
Value _round(List<Value> a, InvokeCallback i) => IntValue(_num(a[0]).round());
Value _trunc(List<Value> a, InvokeCallback i) => IntValue(_num(a[0]).truncate());
Value _sqrt(List<Value> a, InvokeCallback i) => _number(math.sqrt(_num(a[0])));
Value _pow(List<Value> a, InvokeCallback i) => _number(math.pow(_num(a[0]), _num(a[1])).toDouble());
Value _sign(List<Value> a, InvokeCallback i) => IntValue(_num(a[0]).sign.toInt());

Value _mathMin(List<Value> a, InvokeCallback i) =>
    a.isEmpty ? const NumValue(double.infinity) : _number(a.map(_num).reduce(math.min));

Value _mathMax(List<Value> a, InvokeCallback i) =>
    a.isEmpty ? const NumValue(double.negativeInfinity) : _number(a.map(_num).reduce(math.max));

// --- Object / Array statics ------------------------------------------------

Value _objectKeys(List<Value> a, InvokeCallback i) {
  final o = a[0];
  if (o is MapValue) return ListValue(o.entries.keys.toList());
  if (o is InstanceValue) return ListValue(<Value>[for (final k in o.fields.keys) StrValue(k)]);
  if (o is ListValue) {
    return ListValue(<Value>[for (var n = 0; n < o.items.length; n++) StrValue('$n')]);
  }
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'an object'});
}

Value _objectValues(List<Value> a, InvokeCallback i) {
  final o = a[0];
  if (o is MapValue) return ListValue(o.entries.values.toList());
  if (o is InstanceValue) return ListValue(o.fields.values.toList());
  if (o is ListValue) return ListValue(List<Value>.of(o.items));
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'an object'});
}

Value _objectEntries(List<Value> a, InvokeCallback i) {
  final o = a[0];
  if (o is MapValue) {
    return ListValue(<Value>[
      for (final e in o.entries.entries) ListValue(<Value>[e.key, e.value])
    ]);
  }
  if (o is InstanceValue) {
    return ListValue(<Value>[
      for (final e in o.fields.entries) ListValue(<Value>[StrValue(e.key), e.value])
    ]);
  }
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'an object'});
}

Value _objectAssign(List<Value> a, InvokeCallback i) {
  final target = a[0];
  if (target is! MapValue) {
    throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'an object'});
  }
  for (final source in a.skip(1)) {
    if (source is MapValue) target.entries.addAll(source.entries);
  }
  return target;
}

Value _isArray(List<Value> a, InvokeCallback i) => BoolValue(a[0] is ListValue);

Value _arrayFrom(List<Value> a, InvokeCallback i) {
  final items = List<Value>.of(_iter(a[0]));
  if (a.length < 2 || a[1] is NullValue || a[1] is UndefinedValue) return ListValue(items);
  return ListValue(<Value>[
    for (var n = 0; n < items.length; n++) _callback(a[1], <Value>[items[n], IntValue(n)], i),
  ]);
}

Value _arrayOf(List<Value> a, InvokeCallback i) => ListValue(List<Value>.of(a));

Value _isInteger(List<Value> a, InvokeCallback i) {
  final v = a[0];
  if (v is IntValue) return const BoolValue(true);
  if (v is NumValue) return BoolValue(v.value.isFinite && v.value == v.value.roundToDouble());
  return const BoolValue(false);
}

Value _isNan(List<Value> a, InvokeCallback i) {
  final v = a[0];
  if (v is NumValue) return BoolValue(v.value.isNaN);
  if (v is IntValue) return const BoolValue(false);
  if (v is StrValue) return BoolValue(double.tryParse(v.value.trim()) == null);
  return const BoolValue(true);
}

Value _parseInt(List<Value> a, InvokeCallback i) {
  final text = _str(a[0]).trim();
  final radix = a.length > 1 && a[1] is IntValue ? (a[1] as IntValue).value : 10;
  // JavaScript's parseInt reads the longest valid prefix and ignores the rest.
  final match = RegExp(radix == 16 ? r'^[+-]?(0[xX])?[0-9a-fA-F]+' : r'^[+-]?[0-9]+').firstMatch(text);
  if (match == null) return const NumValue(double.nan);
  final parsed = int.tryParse(match.group(0)!.replaceFirst(RegExp('0[xX]'), ''), radix: radix);
  return parsed == null ? const NumValue(double.nan) : IntValue(parsed);
}

Value _parseFloat(List<Value> a, InvokeCallback i) {
  final match = RegExp(r'^[+-]?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?').firstMatch(_str(a[0]).trim());
  if (match == null) return const NumValue(double.nan);
  return _number(double.parse(match.group(0)!));
}

Value _fromCharCode(List<Value> a, InvokeCallback i) => StrValue(String.fromCharCodes(a.map(_int)));

// --- typeof, ==, constructors ----------------------------------------------

Value _typeOf(List<Value> a, InvokeCallback i) => StrValue(switch (a[0]) {
      UndefinedValue() => 'undefined',
      NullValue() => 'object',
      BoolValue() => 'boolean',
      IntValue() || NumValue() => 'number',
      StrValue() => 'string',
      FunctionValue() || NativeFunctionValue() || ClassValue() => 'function',
      _ => 'object',
    });

/// JavaScript's `==`: equal after coercion. `===` is the shared strict
/// opcode, which is why this is a separate function rather than a dialect
/// switch on equality.
Value _looseEq(List<Value> a, InvokeCallback i) {
  final x = a[0];
  final y = a[1];
  // null and undefined equal each other and nothing else.
  final xNullish = x is NullValue || x is UndefinedValue;
  final yNullish = y is NullValue || y is UndefinedValue;
  if (xNullish || yNullish) return BoolValue(xNullish && yNullish);
  if (x.runtimeType == y.runtimeType) return BoolValue(x == y);

  Value coerce(Value v) => v is BoolValue ? IntValue(v.value ? 1 : 0) : v;
  final cx = coerce(x);
  final cy = coerce(y);

  final xNumeric = cx is IntValue || cx is NumValue;
  final yNumeric = cy is IntValue || cy is NumValue;
  if (xNumeric && yNumeric) return BoolValue(_num(cx) == _num(cy));
  if (xNumeric && cy is StrValue) {
    final parsed = double.tryParse(cy.value.trim());
    return BoolValue(parsed != null && parsed == _num(cx));
  }
  if (yNumeric && cx is StrValue) {
    final parsed = double.tryParse(cx.value.trim());
    return BoolValue(parsed != null && parsed == _num(cy));
  }
  return BoolValue(cx == cy);
}

Value _newMap(List<Value> a, InvokeCallback i) {
  final map = MapValue();
  if (a.isEmpty || a[0] is NullValue || a[0] is UndefinedValue) return map;
  for (final pair in _iter(a[0])) {
    final kv = _iter(pair);
    if (kv.length != 2) {
      throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a key/value pair'});
    }
    map.entries[kv[0]] = kv[1];
  }
  return map;
}

Value _newSet(List<Value> a, InvokeCallback i) => SetValue(LinkedHashSet<Value>.of(
    a.isEmpty || a[0] is NullValue || a[0] is UndefinedValue ? <Value>[] : _iter(a[0])));

Value _newArray(List<Value> a, InvokeCallback i) {
  // `new Array(3)` is three empty slots; `new Array(1, 2)` is those elements.
  // JavaScript has one number type, so `new Array(total / 2)` is a length like
  // any other — the engine must not treat a whole `2.0` as "not a count".
  if (a.length == 1) {
    final length = _wholeNumber(a[0]);
    if (length != null) {
      return ListValue(List<Value>.filled(length, UndefinedValue.instance, growable: true));
    }
  }
  return ListValue(List<Value>.of(a));
}

/// [v] as a whole number, or null if it is not one.
int? _wholeNumber(Value v) {
  if (v is IntValue) return v.value;
  if (v is NumValue && v.value.isFinite && v.value == v.value.roundToDouble()) {
    return v.value.toInt();
  }
  return null;
}

// --- Array methods ---------------------------------------------------------

Value _size(List<Value> a, InvokeCallback i) {
  final v = a[0];
  if (v is MapValue) return IntValue(v.entries.length);
  if (v is SetValue) return IntValue(v.items.length);
  if (v is ListValue) return IntValue(v.items.length);
  if (v is StrValue) return IntValue(v.value.length);
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a sized value'});
}

Value _push(List<Value> a, InvokeCallback i) {
  final items = _array(a[0]).items;
  items.addAll(a.skip(1));
  return IntValue(items.length);
}

Value _pop(List<Value> a, InvokeCallback i) {
  final items = _array(a[0]).items;
  return items.isEmpty ? UndefinedValue.instance : items.removeLast();
}

Value _shift(List<Value> a, InvokeCallback i) {
  final items = _array(a[0]).items;
  return items.isEmpty ? UndefinedValue.instance : items.removeAt(0);
}

Value _unshift(List<Value> a, InvokeCallback i) {
  final items = _array(a[0]).items;
  items.insertAll(0, a.skip(1));
  return IntValue(items.length);
}

/// `slice` clamps and accepts negative offsets, on both arrays and strings.
Value _slice(List<Value> a, InvokeCallback i) {
  final receiver = a[0];
  final length = receiver is StrValue ? receiver.value.length : _array(receiver).items.length;
  var start = a.length > 1 && a[1] is! UndefinedValue ? _int(a[1]) : 0;
  var end = a.length > 2 && a[2] is! UndefinedValue && a[2] is! NullValue ? _int(a[2]) : length;
  if (start < 0) start += length;
  if (end < 0) end += length;
  start = start.clamp(0, length);
  end = end.clamp(0, length);
  if (end < start) end = start;
  if (receiver is StrValue) return StrValue(receiver.value.substring(start, end));
  return ListValue(_array(receiver).items.sublist(start, end));
}

Value _splice(List<Value> a, InvokeCallback i) {
  final items = _array(a[0]).items;
  var start = a.length > 1 ? _int(a[1]) : 0;
  if (start < 0) start += items.length;
  start = start.clamp(0, items.length);
  final count = a.length > 2 ? _int(a[2]).clamp(0, items.length - start) : items.length - start;
  final removed = items.sublist(start, start + count);
  items.removeRange(start, start + count);
  if (a.length > 3) items.insertAll(start, a.skip(3));
  return ListValue(removed);
}

Value _concat(List<Value> a, InvokeCallback i) {
  final out = List<Value>.of(_array(a[0]).items);
  for (final extra in a.skip(1)) {
    if (extra is ListValue) {
      out.addAll(extra.items);
    } else {
      out.add(extra);
    }
  }
  return ListValue(out);
}

/// `join` defaults to a comma, unlike every other language here.
Value _join(List<Value> a, InvokeCallback i) {
  final sep = a.length > 1 && a[1] is! UndefinedValue ? _str(a[1]) : ',';
  return StrValue(_iter(a[0]).map(_display).join(sep));
}

Value _reverse(List<Value> a, InvokeCallback i) {
  final items = _array(a[0]).items;
  final flipped = items.reversed.toList();
  items
    ..clear()
    ..addAll(flipped);
  return a[0];
}

/// Sorts **in place**, returns the array, and with no comparator compares the
/// elements *as strings* — so `[10, 9, 1].sort()` is `[1, 10, 9]`.
Value _sort(List<Value> a, InvokeCallback i) {
  final items = _array(a[0]).items;
  final comparator = a.length > 1 && a[1] is FunctionValue ? a[1] : null;
  if (comparator == null) {
    items.sort((x, y) => _display(x).compareTo(_display(y)));
  } else {
    items.sort((x, y) {
      final result = _callback(comparator, <Value>[x, y], i);
      final n = _num(result);
      return n < 0 ? -1 : (n > 0 ? 1 : 0);
    });
  }
  return a[0];
}

Value _map(List<Value> a, InvokeCallback i) {
  final items = _iter(a[0]);
  return ListValue(<Value>[
    for (var n = 0; n < items.length; n++) _callback(a[1], <Value>[items[n], IntValue(n), a[0]], i),
  ]);
}

Value _filter(List<Value> a, InvokeCallback i) {
  final items = _iter(a[0]);
  return ListValue(<Value>[
    for (var n = 0; n < items.length; n++)
      if (_truthy(_callback(a[1], <Value>[items[n], IntValue(n), a[0]], i))) items[n],
  ]);
}

Value _reduce(List<Value> a, InvokeCallback i) {
  final items = _iter(a[0]);
  var start = 0;
  Value accumulator;
  if (a.length > 2) {
    accumulator = a[2];
  } else {
    if (items.isEmpty) {
      throw const VmRuntimeError('runtime', <String, Object?>{'message': 'reduce of an empty array'});
    }
    accumulator = items.first;
    start = 1;
  }
  for (var n = start; n < items.length; n++) {
    accumulator = _callback(a[1], <Value>[accumulator, items[n], IntValue(n), a[0]], i);
  }
  return accumulator;
}

Value _forEach(List<Value> a, InvokeCallback i) {
  final items = _iter(a[0]);
  for (var n = 0; n < items.length; n++) {
    _callback(a[1], <Value>[items[n], IntValue(n), a[0]], i);
  }
  return UndefinedValue.instance;
}

Value _find(List<Value> a, InvokeCallback i) {
  final items = _iter(a[0]);
  for (var n = 0; n < items.length; n++) {
    if (_truthy(_callback(a[1], <Value>[items[n], IntValue(n), a[0]], i))) return items[n];
  }
  return UndefinedValue.instance;
}

Value _findIndex(List<Value> a, InvokeCallback i) {
  final items = _iter(a[0]);
  for (var n = 0; n < items.length; n++) {
    if (_truthy(_callback(a[1], <Value>[items[n], IntValue(n), a[0]], i))) return IntValue(n);
  }
  return const IntValue(-1);
}

Value _some(List<Value> a, InvokeCallback i) {
  final items = _iter(a[0]);
  for (var n = 0; n < items.length; n++) {
    if (_truthy(_callback(a[1], <Value>[items[n], IntValue(n), a[0]], i))) return const BoolValue(true);
  }
  return const BoolValue(false);
}

Value _every(List<Value> a, InvokeCallback i) {
  final items = _iter(a[0]);
  for (var n = 0; n < items.length; n++) {
    if (!_truthy(_callback(a[1], <Value>[items[n], IntValue(n), a[0]], i))) return const BoolValue(false);
  }
  return const BoolValue(true);
}

Value _flat(List<Value> a, InvokeCallback i) {
  final depth = a.length > 1 ? _int(a[1]) : 1;
  List<Value> flatten(List<Value> items, int remaining) => <Value>[
        for (final item in items)
          if (item is ListValue && remaining > 0) ...flatten(item.items, remaining - 1) else item,
      ];
  return ListValue(flatten(_array(a[0]).items, depth));
}

Value _fill(List<Value> a, InvokeCallback i) {
  final items = _array(a[0]).items;
  final from = a.length > 2 ? _int(a[2]).clamp(0, items.length) : 0;
  final to = a.length > 3 ? _int(a[3]).clamp(0, items.length) : items.length;
  for (var n = from; n < to; n++) {
    items[n] = a[1];
  }
  return a[0];
}

Value _indexOf(List<Value> a, InvokeCallback i) {
  final receiver = a[0];
  if (receiver is StrValue) return IntValue(receiver.value.indexOf(_str(a[1])));
  return IntValue(_iter(receiver).indexOf(a[1]));
}

Value _lastIndexOf(List<Value> a, InvokeCallback i) {
  final receiver = a[0];
  if (receiver is StrValue) return IntValue(receiver.value.lastIndexOf(_str(a[1])));
  return IntValue(_iter(receiver).lastIndexOf(a[1]));
}

Value _includes(List<Value> a, InvokeCallback i) {
  final receiver = a[0];
  if (receiver is StrValue) return BoolValue(receiver.value.contains(_str(a[1])));
  if (receiver is SetValue) return BoolValue(receiver.items.contains(a[1]));
  return BoolValue(_iter(receiver).contains(a[1]));
}

/// `at` is the one place JavaScript does index from the end.
Value _at(List<Value> a, InvokeCallback i) {
  final receiver = a[0];
  final length = receiver is StrValue ? receiver.value.length : _iter(receiver).length;
  var n = _int(a[1]);
  if (n < 0) n += length;
  if (n < 0 || n >= length) return UndefinedValue.instance;
  if (receiver is StrValue) return StrValue(receiver.value[n]);
  return _iter(receiver)[n];
}

// --- String methods --------------------------------------------------------

Value _charAt(List<Value> a, InvokeCallback i) {
  final s = _str(a[0]);
  final n = a.length > 1 ? _int(a[1]) : 0;
  return StrValue(n >= 0 && n < s.length ? s[n] : '');
}

Value _charCodeAt(List<Value> a, InvokeCallback i) {
  final s = _str(a[0]);
  final n = a.length > 1 ? _int(a[1]) : 0;
  if (n < 0 || n >= s.length) return const NumValue(double.nan);
  return IntValue(s.codeUnitAt(n));
}

/// `substring` swaps its bounds when they are the wrong way round, and
/// clamps negatives to zero rather than counting from the end.
Value _substring(List<Value> a, InvokeCallback i) {
  final s = _str(a[0]);
  var start = (a.length > 1 ? _int(a[1]) : 0).clamp(0, s.length);
  var end = (a.length > 2 && a[2] is! UndefinedValue ? _int(a[2]) : s.length).clamp(0, s.length);
  if (start > end) {
    final swap = start;
    start = end;
    end = swap;
  }
  return StrValue(s.substring(start, end));
}

Value _split(List<Value> a, InvokeCallback i) {
  final s = _str(a[0]);
  if (a.length < 2 || a[1] is UndefinedValue) return ListValue(<Value>[StrValue(s)]);
  final sep = _str(a[1]);
  if (sep.isEmpty) return ListValue(<Value>[for (final c in s.split('')) StrValue(c)]);
  return ListValue(<Value>[for (final p in s.split(sep)) StrValue(p)]);
}

/// `replace` replaces only the first occurrence; `replaceAll` all of them.
Value _replaceFirst(List<Value> a, InvokeCallback i) =>
    StrValue(_str(a[0]).replaceFirst(_str(a[1]), _str(a[2])));

Value _replaceAll(List<Value> a, InvokeCallback i) => StrValue(_str(a[0]).replaceAll(_str(a[1]), _str(a[2])));

Value _pad(List<Value> a, {required bool start}) {
  final s = _str(a[0]);
  final width = _int(a[1]);
  final fill = a.length > 2 && a[2] is StrValue ? (a[2] as StrValue).value : ' ';
  if (fill.isEmpty || s.length >= width) return StrValue(s);
  final needed = width - s.length;
  final padding = (fill * (needed ~/ fill.length + 1)).substring(0, needed);
  return StrValue(start ? padding + s : s + padding);
}

Value _toFixed(List<Value> a, InvokeCallback i) =>
    StrValue(_num(a[0]).toStringAsFixed(a.length > 1 ? _int(a[1]) : 0));

// --- Map and Set methods ---------------------------------------------------

Value _mapGet(List<Value> a, InvokeCallback i) {
  final receiver = a[0];
  if (receiver is! MapValue) {
    throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a Map'});
  }
  return receiver.entries[a[1]] ?? UndefinedValue.instance;
}

Value _mapSet(List<Value> a, InvokeCallback i) {
  final receiver = a[0];
  if (receiver is! MapValue) {
    throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a Map'});
  }
  receiver.entries[a[1]] = a.length > 2 ? a[2] : UndefinedValue.instance;
  return receiver;
}

Value _has(List<Value> a, InvokeCallback i) {
  final receiver = a[0];
  if (receiver is MapValue) return BoolValue(receiver.entries.containsKey(a[1]));
  if (receiver is SetValue) return BoolValue(receiver.items.contains(a[1]));
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a Map or Set'});
}

Value _delete(List<Value> a, InvokeCallback i) {
  final receiver = a[0];
  if (receiver is MapValue) return BoolValue(receiver.entries.remove(a[1]) != null);
  if (receiver is SetValue) return BoolValue(receiver.items.remove(a[1]));
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a Map or Set'});
}

Value _add(List<Value> a, InvokeCallback i) {
  final receiver = a[0];
  if (receiver is SetValue) {
    receiver.items.add(a[1]);
    return receiver;
  }
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a Set'});
}

Value _keysOf(List<Value> a, InvokeCallback i) {
  final receiver = a[0];
  if (receiver is MapValue) return ListValue(receiver.entries.keys.toList());
  if (receiver is SetValue) return ListValue(receiver.items.toList());
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a Map or Set'});
}

Value _valuesOf(List<Value> a, InvokeCallback i) {
  final receiver = a[0];
  if (receiver is MapValue) return ListValue(receiver.entries.values.toList());
  if (receiver is SetValue) return ListValue(receiver.items.toList());
  if (receiver is ListValue) return ListValue(List<Value>.of(receiver.items));
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a Map or Set'});
}

Value _entriesOf(List<Value> a, InvokeCallback i) {
  final receiver = a[0];
  if (receiver is MapValue) {
    return ListValue(<Value>[
      for (final e in receiver.entries.entries) ListValue(<Value>[e.key, e.value])
    ]);
  }
  if (receiver is ListValue) {
    return ListValue(<Value>[
      for (var n = 0; n < receiver.items.length; n++) ListValue(<Value>[IntValue(n), receiver.items[n]]),
    ]);
  }
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a Map'});
}
