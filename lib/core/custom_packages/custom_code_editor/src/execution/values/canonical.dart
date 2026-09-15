/// The language-neutral form used for grading (FR-010a).
/// See `specs/007-multi-language-interpreter/data-model.md` §3 and
/// `contracts/grading-contract.md`.
library;

import 'value.dart';

/// Language-neutral value. Comparison happens here, never on printed text.
sealed class CanonicalValue {
  const CanonicalValue();
}

class CInt extends CanonicalValue {
  const CInt(this.value);
  final int value;

  @override
  bool operator ==(Object other) => other is CInt && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => 'CInt($value)';
}

class CNum extends CanonicalValue {
  const CNum(this.value);
  final double value;

  @override
  bool operator ==(Object other) => other is CNum && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => 'CNum($value)';
}

class CBool extends CanonicalValue {
  const CBool(this.value);
  final bool value;

  @override
  bool operator ==(Object other) => other is CBool && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => 'CBool($value)';
}

class CStr extends CanonicalValue {
  const CStr(this.value);
  final String value;

  @override
  bool operator ==(Object other) => other is CStr && other.value == value;
  @override
  int get hashCode => value.hashCode;
  @override
  String toString() => 'CStr($value)';
}

class CNull extends CanonicalValue {
  const CNull._();
  static const CNull instance = CNull._();

  @override
  bool operator ==(Object other) => other is CNull;
  @override
  int get hashCode => 0;
  @override
  String toString() => 'CNull';
}

/// Produced from both `ListValue` and `TupleValue` (rule 3 — tuples and
/// lists both become `CList`). Order-sensitive.
class CList extends CanonicalValue {
  const CList(this.items);
  final List<CanonicalValue> items;

  @override
  bool operator ==(Object other) {
    if (other is! CList) return false;
    if (other.items.length != items.length) return false;
    for (var i = 0; i < items.length; i++) {
      if (items[i] != other.items[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(items);
  @override
  String toString() => 'CList($items)';
}

/// Key order preserved.
class CMap extends CanonicalValue {
  const CMap(this.entries);
  final List<MapEntry<CanonicalValue, CanonicalValue>> entries;

  @override
  bool operator ==(Object other) {
    if (other is! CMap) return false;
    if (other.entries.length != entries.length) return false;
    for (final entry in entries) {
      final match = other.entries.where((e) => e.key == entry.key);
      if (match.isEmpty || match.first.value != entry.value) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAllUnordered(entries.map((e) => Object.hash(e.key, e.value)));
  @override
  String toString() => 'CMap($entries)';
}

class CSet extends CanonicalValue {
  const CSet(this.items);
  final List<CanonicalValue> items;

  @override
  bool operator ==(Object other) {
    if (other is! CSet) return false;
    if (other.items.length != items.length) return false;
    return items.every((i) => other.items.contains(i));
  }

  @override
  int get hashCode => Object.hashAllUnordered(items);
  @override
  String toString() => 'CSet($items)';
}

/// A structured instance (linked list, tree, ...) matching a known shape.
/// `shape` names the structure (e.g. `"ListNode"`); `fields` are its
/// canonicalized field values in declaration order. Full integration with
/// `testcase/object_serializer.dart`'s shape metadata and cycle guard is
/// Phase 6 (US6) work — this shape exists now so the normalizer's type is
/// complete per data-model.md §3.
class CNode extends CanonicalValue {
  const CNode(this.shape, this.fields);
  final String shape;
  final Map<String, CanonicalValue> fields;

  @override
  bool operator ==(Object other) {
    if (other is! CNode) return false;
    if (other.shape != shape) return false;
    if (other.fields.length != fields.length) return false;
    for (final key in fields.keys) {
      if (!other.fields.containsKey(key)) return false;
      if (other.fields[key] != fields[key]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      Object.hash(shape, Object.hashAllUnordered(fields.entries.map((e) => Object.hash(e.key, e.value))));
  @override
  String toString() => 'CNode($shape, $fields)';
}

/// Converts a runtime [Value] to its [CanonicalValue] per the five
/// normalization rules in data-model.md §3:
///
/// 1. Whole-number floats collapse to [CInt].
/// 2. `undefined`/`None`/`null` all become [CNull].
/// 3. Tuples and lists both become [CList].
/// 4. Structured instances become [CNode] via shape metadata (Phase 6).
/// 5. Nothing else is collapsed — type, value, structure and order (where it
///    matters) all still distinguish.
CanonicalValue normalize(Value value) {
  switch (value) {
    case IntValue(:final value):
      return CInt(value);
    case NumValue(:final value):
      // Rule 1: a whole-number float collapses to CInt.
      if (value.isFinite && value == value.roundToDouble()) {
        return CInt(value.toInt());
      }
      return CNum(value);
    case BoolValue(:final value):
      return CBool(value);
    case StrValue(:final value):
      return CStr(value);
    case NullValue():
    case UndefinedValue():
      // Rule 2.
      return CNull.instance;
    case ListValue(:final items):
      // Rule 3.
      return CList(items.map(normalize).toList(growable: false));
    case TupleValue(:final items):
      // Rule 3.
      return CList(items.map(normalize).toList(growable: false));
    case MapValue(:final entries):
      return CMap(
          entries.entries.map((e) => MapEntry(normalize(e.key), normalize(e.value))).toList(growable: false));
    case SetValue(:final items):
      return CSet(items.map(normalize).toList(growable: false));
    case InstanceValue(:final klass, :final fields):
      // Rule 4 (minimal form; full shape-aware form lands in Phase 6).
      return CNode(klass.name, fields.map((k, v) => MapEntry(k, normalize(v))));
    case FunctionValue():
    case ClassValue():
    case ErrorValue():
    case NativeFunctionValue():
    case IntrinsicMethod():
    case NamespaceValue():
      throw ArgumentError('$value has no canonical grading representation');
  }
}
