/// Collection built-ins: `map`, `where`, `sort`, `reduce`, `fold`, and
/// friends (FR-002). This is the surface that unblocks the original
/// complaint — `.map`/`.where`/`sort(cmp)`/`.reduce` all live here.
library;

import 'dart:collection';

import '../errors/failure.dart';
import '../values/dialect.dart';
import '../values/value.dart';

/// Immediate (argument-less) properties on a list/tuple: `.length`,
/// `.isEmpty`, ... Returns `null` when [name] isn't one of these, meaning
/// the caller should try [callListMethod] instead.
Value? getListProperty(List<Value> items, String name) {
  switch (name) {
    case 'length':
      return IntValue(items.length);
    case 'isEmpty':
      return BoolValue(items.isEmpty);
    case 'isNotEmpty':
      return BoolValue(items.isNotEmpty);
    case 'first':
      if (items.isEmpty) throw const VmRuntimeError('indexOutOfRange', <String, Object?>{'index': 0, 'length': 0});
      return items.first;
    case 'last':
      if (items.isEmpty) throw const VmRuntimeError('indexOutOfRange', <String, Object?>{'index': -1, 'length': 0});
      return items.last;
    case 'reversed':
      return ListValue(items.reversed.toList());
    default:
      return null;
  }
}

Value callListMethod(ListValue receiver, String name, List<Value> args, InvokeCallback invoke, Dialect dialect) {
  final items = receiver.items;
  switch (name) {
    case 'map':
      final f = _fn(args, 0);
      return ListValue(items.map((e) => invoke(f, <Value>[e])).toList());
    case 'where':
      final f = _fn(args, 0);
      return ListValue(items.where((e) => isTruthy(invoke(f, <Value>[e]), dialect)).toList());
    case 'expand':
      final f = _fn(args, 0);
      final result = <Value>[];
      for (final e in items) {
        final sub = invoke(f, <Value>[e]);
        result.addAll(_asIterable(sub));
      }
      return ListValue(result);
    case 'sort':
      if (args.isEmpty) {
        items.sort((a, b) => compareValues(a, b, dialect));
      } else {
        final f = _fn(args, 0);
        items.sort((a, b) => (invoke(f, <Value>[a, b]) as IntValue).value);
      }
      return receiver;
    case 'reduce':
      final f = _fn(args, 0);
      if (items.isEmpty) throw const VmRuntimeError('runtime', <String, Object?>{'message': 'reduce on an empty collection'});
      var acc = items.first;
      for (var i = 1; i < items.length; i++) {
        acc = invoke(f, <Value>[acc, items[i]]);
      }
      return acc;
    case 'fold':
      final initial = args[0];
      final f = _fn(args, 1);
      var acc = initial;
      for (final e in items) {
        acc = invoke(f, <Value>[acc, e]);
      }
      return acc;
    case 'any':
      final f = _fn(args, 0);
      return BoolValue(items.any((e) => isTruthy(invoke(f, <Value>[e]), dialect)));
    case 'every':
      final f = _fn(args, 0);
      return BoolValue(items.every((e) => isTruthy(invoke(f, <Value>[e]), dialect)));
    case 'firstWhere':
      final f = _fn(args, 0);
      for (final e in items) {
        if (isTruthy(invoke(f, <Value>[e]), dialect)) return e;
      }
      throw const VmRuntimeError('runtime', <String, Object?>{'message': 'no element satisfies the predicate'});
    case 'indexWhere':
      final f = _fn(args, 0);
      for (var i = 0; i < items.length; i++) {
        if (isTruthy(invoke(f, <Value>[items[i]]), dialect)) return IntValue(i);
      }
      return const IntValue(-1);
    case 'contains':
      return BoolValue(items.contains(args[0]));
    case 'indexOf':
      return IntValue(items.indexOf(args[0]));
    case 'join':
      final sep = args.isEmpty ? '' : (args[0] as StrValue).value;
      return StrValue(items.map((e) => displayString(e, dialect)).join(sep));
    case 'take':
      final n = (args[0] as IntValue).value;
      return ListValue(items.take(n).toList());
    case 'skip':
      final n = (args[0] as IntValue).value;
      return ListValue(items.skip(n).toList());
    case 'sublist':
      final start = (args[0] as IntValue).value;
      final end = args.length > 1 ? (args[1] as IntValue).value : items.length;
      if (start < 0 || end > items.length || start > end) {
        throw VmRuntimeError('indexOutOfRange', <String, Object?>{'index': start, 'length': items.length});
      }
      return ListValue(items.sublist(start, end));
      case 'toList':
      return ListValue(List<Value>.of(items));
    case 'toSet':
      return SetValue(LinkedHashSet<Value>.of(items));
    case 'add':
      items.add(args[0]);
      return NullValue.instance;
    case 'addAll':
      items.addAll(_asIterable(args[0]));
      return NullValue.instance;
    case 'remove':
      return BoolValue(items.remove(args[0]));
    case 'removeAt':
      final idx = (args[0] as IntValue).value;
      if (idx < 0 || idx >= items.length) throw VmRuntimeError('indexOutOfRange', <String, Object?>{'index': idx, 'length': items.length});
      return items.removeAt(idx);
    case 'removeLast':
      if (items.isEmpty) throw const VmRuntimeError('indexOutOfRange', <String, Object?>{'index': -1, 'length': 0});
      return items.removeLast();
    case 'insert':
      final idx = (args[0] as IntValue).value;
      items.insert(idx, args[1]);
      return NullValue.instance;
    case 'clear':
      items.clear();
      return NullValue.instance;
    case 'asMap':
      final map = MapValue();
      for (var i = 0; i < items.length; i++) {
        map.entries[IntValue(i)] = items[i];
      }
      return map;
    default:
      throw VmRuntimeError('undefinedFunction', <String, Object?>{'name': name});
  }
}

FunctionValue _fn(List<Value> args, int index) {
  final v = args[index];
  if (v is FunctionValue) return v;
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a function'});
}

Iterable<Value> _asIterable(Value v) {
  if (v is ListValue) return v.items;
  if (v is TupleValue) return v.items;
  if (v is SetValue) return v.items;
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'an iterable'});
}
