// ignore_for_file: prefer_collection_literals

/// The shared runtime value space every language frontend produces and the
/// VM consumes. See `specs/007-multi-language-interpreter/data-model.md` §2.
library;

import 'dart:collection';

import '../errors/failure.dart';
import 'dialect.dart';

/// Base type for every runtime value. Structural kinds (int/num/bool/str/
/// null/undefined/list/tuple/map/set) compare and hash structurally.
/// [FunctionValue], [ClassValue] and [InstanceValue] compare by identity.
sealed class Value {
  const Value();
}

class IntValue extends Value {
  const IntValue(this.value);
  final int value;

  @override
  bool operator ==(Object other) => other is IntValue && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => 'IntValue($value)';
}

class NumValue extends Value {
  const NumValue(this.value);
  final double value;

  @override
  bool operator ==(Object other) => other is NumValue && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => 'NumValue($value)';
}

class BoolValue extends Value {
  const BoolValue(this.value);
  final bool value;

  static const BoolValue trueValue = BoolValue(true);
  static const BoolValue falseValue = BoolValue(false);

  @override
  bool operator ==(Object other) => other is BoolValue && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => 'BoolValue($value)';
}

class StrValue extends Value {
  const StrValue(this.value);
  final String value;

  @override
  bool operator ==(Object other) => other is StrValue && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => 'StrValue(${value.length > 40 ? '${value.substring(0, 40)}...' : value})';
}

/// Dart `null`, Python `None`, JS `null`.
class NullValue extends Value {
  const NullValue._();
  static const NullValue instance = NullValue._();

  @override
  bool operator ==(Object other) => other is NullValue;
  @override
  int get hashCode => 0;
  @override
  String toString() => 'NullValue';
}

/// JavaScript only — distinct from [NullValue] at runtime, but both
/// normalize to `CNull` for grading.
class UndefinedValue extends Value {
  const UndefinedValue._();
  static const UndefinedValue instance = UndefinedValue._();

  @override
  bool operator ==(Object other) => other is UndefinedValue;
  @override
  int get hashCode => 1;
  @override
  String toString() => 'UndefinedValue';
}

/// Dart `List`, Python `list`, JS `Array`. Mutable.
class ListValue extends Value {
  ListValue(this.items);
  final List<Value> items;

  @override
  bool operator ==(Object other) {
    if (other is! ListValue) return false;
    if (other.items.length != items.length) return false;
    for (var i = 0; i < items.length; i++) {
      if (items[i] != other.items[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(items);
  @override
  String toString() => 'ListValue($items)';
}

/// Python only. Immutable.
class TupleValue extends Value {
  const TupleValue(this.items);
  final List<Value> items;

  @override
  bool operator ==(Object other) {
    if (other is! TupleValue) return false;
    if (other.items.length != items.length) return false;
    for (var i = 0; i < items.length; i++) {
      if (items[i] != other.items[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(items);
  @override
  String toString() => 'TupleValue($items)';
}

/// Insertion-ordered in all three languages.
class MapValue extends Value {
  MapValue([LinkedHashMap<Value, Value>? entries]) : entries = entries ?? LinkedHashMap<Value, Value>();
  final LinkedHashMap<Value, Value> entries;

  @override
  bool operator ==(Object other) {
    if (other is! MapValue) return false;
    if (other.entries.length != entries.length) return false;
    for (final key in entries.keys) {
      if (!other.entries.containsKey(key)) return false;
      if (other.entries[key] != entries[key]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAllUnordered(entries.entries.map((e) => Object.hash(e.key, e.value)));
  @override
  String toString() => 'MapValue($entries)';
}

/// Insertion-ordered in all three languages.
class SetValue extends Value {
  SetValue([LinkedHashSet<Value>? items]) : items = items ?? LinkedHashSet<Value>();
  final LinkedHashSet<Value> items;

  @override
  bool operator ==(Object other) {
    if (other is! SetValue) return false;
    if (other.items.length != items.length) return false;
    return items.every(other.items.contains);
  }

  @override
  int get hashCode => Object.hashAllUnordered(items);
  @override
  String toString() => 'SetValue($items)';
}

/// A mutable box around a local variable's value. Every local is boxed so
/// that a closure capturing it shares the exact same cell — reads and writes
/// through either the outer scope or the closure observe each other, and the
/// cell outlives the frame that created it. Simpler than tracking open vs.
/// closed upvalues at the cost of one extra indirection per local access,
/// which is fine at interview scale (n ≤ ~10⁴, ~20 test cases per run).
class Cell {
  Cell(this.value);
  Value value;
}

/// The single change that unblocks `.map`/`.where`/`sort(cmp)`/`reduce`:
/// functions are values. Compares by identity.
class FunctionValue extends Value {
  FunctionValue(
      {required this.name,
      required this.arity,
      required this.chunk,
      this.upvalues = const <Cell>[],
      this.boundThis});
  final String name;
  final int arity;

  /// The compiled function body. Typed `Object` here to avoid a dependency
  /// cycle with `vm/chunk.dart`; the VM casts it back to `FunctionProto`.
  final Object chunk;

  /// Cells captured from enclosing scopes at closure-creation time.
  final List<Cell> upvalues;

  /// Set when this is a bound method (`instance.method`).
  final InstanceValue? boundThis;

  /// The class this closure was compiled as a method of, set once by the VM
  /// when the `CLASS`/`METHOD` opcodes build a [ClassValue]. Used to resolve
  /// `super.method(...)` — never set for a plain function or lambda.
  ClassValue? homeClass;

  FunctionValue bindTo(InstanceValue instance) =>
      FunctionValue(name: name, arity: arity, chunk: chunk, upvalues: upvalues, boundThis: instance)
        ..homeClass = homeClass;

  @override
  bool operator ==(Object other) => identical(this, other);
  @override
  int get hashCode => identityHashCode(this);
  @override
  String toString() => 'FunctionValue($name/$arity)';
}

/// Single inheritance (FR-002b).
class ClassValue extends Value {
  ClassValue({required this.name, this.superclass, Map<String, FunctionValue>? methods})
      : methods = methods ?? <String, FunctionValue>{};
  final String name;
  final ClassValue? superclass;
  final Map<String, FunctionValue> methods;

  FunctionValue? findMethod(String name) {
    return methods[name] ?? superclass?.findMethod(name);
  }

  @override
  bool operator ==(Object other) => identical(this, other);
  @override
  int get hashCode => identityHashCode(this);
  @override
  String toString() => 'ClassValue($name)';
}

/// Replaces the legacy engine's `ObjectInstance`; carries the same shape
/// metadata the grader needs.
class InstanceValue extends Value {
  InstanceValue(this.klass, [Map<String, Value>? fields]) : fields = fields ?? <String, Value>{};
  final ClassValue klass;
  final Map<String, Value> fields;

  @override
  bool operator ==(Object other) => identical(this, other);
  @override
  int get hashCode => identityHashCode(this);
  @override
  String toString() => 'InstanceValue(${klass.name}, $fields)';
}

/// A thrown/raised value (FR-002c). Carries a classification, a stable
/// message code (no English prose — research decision 7) and the language
/// value that was actually thrown, when the learner threw one explicitly.
class ErrorValue extends Value {
  const ErrorValue({required this.code, this.data = const <String, Object?>{}, this.thrownValue});
  final String code;
  final Map<String, Object?> data;
  final Value? thrownValue;

  @override
  bool operator ==(Object other) => other is ErrorValue && other.code == code;
  @override
  int get hashCode => code.hashCode;
  @override
  String toString() => 'ErrorValue($code, $data)';
}

/// Lets a stdlib intrinsic (e.g. `list.map(f)`) invoke a learner-supplied
/// closure without the `stdlib/` layer depending on the VM.
typedef InvokeCallback = Value Function(FunctionValue fn, List<Value> args);

/// A builtin free/static function (e.g. `int.parse`, `List.generate`, `min`).
/// `arity == -1` means variadic; the implementation validates argument count
/// itself.
class NativeFunctionValue extends Value {
  const NativeFunctionValue(this.name, this.arity, this.call);
  final String name;
  final int arity;
  final Value Function(List<Value> args, InvokeCallback invoke) call;

  @override
  bool operator ==(Object other) => identical(this, other);
  @override
  int get hashCode => identityHashCode(this);
  @override
  String toString() => 'NativeFunctionValue($name)';
}

/// A builtin instance method bound to its receiver (`list.map`, `"a".split`,
/// ...), produced by property access on a structural value. Only ever valid
/// as the immediate callee of a call — see `vm/vm.dart`'s `CALL` handling.
class IntrinsicMethod extends Value {
  const IntrinsicMethod(this.receiver, this.name);
  final Value receiver;
  final String name;

  @override
  bool operator ==(Object other) => identical(this, other);
  @override
  int get hashCode => identityHashCode(this);
  @override
  String toString() => 'IntrinsicMethod($name on $receiver)';
}

/// A namespace of static members (`int`, `List`, `Math`, ...) bound to a
/// global identifier. Only ever used for `Namespace.member` access.
class NamespaceValue extends Value {
  const NamespaceValue(this.name, this.members);
  final String name;
  final Map<String, Value> members;

  @override
  bool operator ==(Object other) => identical(this, other);
  @override
  int get hashCode => identityHashCode(this);
  @override
  String toString() => 'NamespaceValue($name)';
}

/// Truthiness per [Dialect.truthiness] (FR consulted by the shared runtime,
/// never special-cased inline in a frontend — O5).
bool isTruthy(Value v, Dialect dialect) => switch (dialect.truthiness) {
      TruthinessMode.boolOnly => v is BoolValue && v.value,
      TruthinessMode.pythonic => _pythonicTruthy(v),
      TruthinessMode.jsLike => _jsTruthy(v),
    };

bool _pythonicTruthy(Value v) {
  if (v is BoolValue) return v.value;
  if (v is NullValue) return false;
  if (v is IntValue) return v.value != 0;
  if (v is NumValue) return v.value != 0;
  if (v is StrValue) return v.value.isNotEmpty;
  if (v is ListValue) return v.items.isNotEmpty;
  if (v is TupleValue) return v.items.isNotEmpty;
  if (v is MapValue) return v.entries.isNotEmpty;
  if (v is SetValue) return v.items.isNotEmpty;
  return true;
}

bool _jsTruthy(Value v) {
  if (v is BoolValue) return v.value;
  if (v is NullValue || v is UndefinedValue) return false;
  if (v is IntValue) return v.value != 0;
  if (v is NumValue) return v.value != 0 && !v.value.isNaN;
  if (v is StrValue) return v.value.isNotEmpty;
  return true;
}

double _asNum(Value v) {
  if (v is IntValue) return v.value.toDouble();
  if (v is NumValue) return v.value;
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a number'});
}

/// Ordering per [Dialect.defaultSortOrder] and O5 (never special-cased
/// inline in a frontend). Used by the VM's comparison opcodes and by the
/// default (no-comparator) `sort`.
int compareValues(Value a, Value b, Dialect dialect) {
  if ((a is IntValue || a is NumValue) && (b is IntValue || b is NumValue)) {
    return _asNum(a).compareTo(_asNum(b));
  }
  if (a is StrValue && b is StrValue) {
    return a.value.compareTo(b.value);
  }
  if (a is BoolValue && b is BoolValue) {
    return (a.value ? 1 : 0).compareTo(b.value ? 1 : 0);
  }
  if (dialect.defaultSortOrder == SortOrder.lexicographic) {
    return _displayString(a).compareTo(_displayString(b));
  }
  throw VmRuntimeError('typeMismatch',
      <String, Object?>{'expected': 'comparable values', 'actual': '${a.runtimeType} and ${b.runtimeType}'});
}

/// Dialect-aware `toString()` used by string interpolation and the
/// lexicographic-sort fallback (JavaScript's default `Array.sort`).
String displayString(Value v, Dialect dialect) => _displayString(v, dialect);

String _displayString(Value v, [Dialect? dialect]) {
  if (v is StrValue) return v.value;
  if (v is IntValue) return v.value.toString();
  if (v is NumValue) {
    if ((dialect?.wholeFloatsPrintAsIntegers ?? false) &&
        v.value.isFinite &&
        v.value == v.value.roundToDouble()) {
      return v.value.toInt().toString();
    }
    return v.value.toString();
  }
  if (v is BoolValue) {
    return v.value ? (dialect?.printsTrueAs ?? 'true') : (dialect?.printsFalseAs ?? 'false');
  }
  if (v is NullValue) return dialect?.printsNullAs ?? 'null';
  if (v is UndefinedValue) return 'undefined';
  if (v is ListValue) return '[${v.items.map((e) => _displayString(e, dialect)).join(', ')}]';
  if (v is TupleValue) return '(${v.items.map((e) => _displayString(e, dialect)).join(', ')})';
  if (v is SetValue) return '{${v.items.map((e) => _displayString(e, dialect)).join(', ')}}';
  if (v is MapValue) {
    return '{${v.entries.entries.map((e) => '${_displayString(e.key, dialect)}: ${_displayString(e.value, dialect)}').join(', ')}}';
  }
  if (v is InstanceValue) return "Instance of '${v.klass.name}'";
  return v.toString();
}
