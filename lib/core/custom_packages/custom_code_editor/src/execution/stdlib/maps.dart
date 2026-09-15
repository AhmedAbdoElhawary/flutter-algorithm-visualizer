/// Map/Set built-ins: keys, values, entries, containsKey, putIfAbsent,
/// update, remove, union/intersection/difference.
library;

import 'dart:collection';

import '../errors/failure.dart';
import '../values/dialect.dart';
import '../values/value.dart';

Value? getMapProperty(MapValue receiver, String name) {
  switch (name) {
    case 'length':
      return IntValue(receiver.entries.length);
    case 'isEmpty':
      return BoolValue(receiver.entries.isEmpty);
    case 'isNotEmpty':
      return BoolValue(receiver.entries.isNotEmpty);
    case 'keys':
      return ListValue(receiver.entries.keys.toList());
    case 'values':
      return ListValue(receiver.entries.values.toList());
    case 'entries':
      return ListValue(receiver.entries.entries.map<Value>((e) {
        final pair = MapValue();
        pair.entries[const StrValue('key')] = e.key;
        pair.entries[const StrValue('value')] = e.value;
        return pair;
      }).toList());
    default:
      return null;
  }
}

Value callMapMethod(
    MapValue receiver, String name, List<Value> args, InvokeCallback invoke, Dialect dialect) {
  final entries = receiver.entries;
  switch (name) {
    case 'containsKey':
      return BoolValue(entries.containsKey(args[0]));
    case 'containsValue':
      return BoolValue(entries.containsValue(args[0]));
    case 'putIfAbsent':
      final key = args[0];
      final f = args[1] as FunctionValue;
      if (!entries.containsKey(key)) entries[key] = invoke(f, const <Value>[]);
      return entries[key]!;
    case 'update':
      final key = args[0];
      final f = args[1] as FunctionValue;
      if (entries.containsKey(key)) {
        entries[key] = invoke(f, <Value>[entries[key]!]);
      } else if (args.length > 2) {
        entries[key] = invoke(args[2] as FunctionValue, const <Value>[]);
      } else {
        throw VmRuntimeError('keyNotFound', <String, Object?>{'key': displayString(key, dialect)});
      }
      return entries[key]!;
    case 'remove':
      return entries.remove(args[0]) ?? NullValue.instance;
    case 'clear':
      entries.clear();
      return NullValue.instance;
    case 'forEach':
      final f = args[0] as FunctionValue;
      for (final e in entries.entries.toList()) {
        invoke(f, <Value>[e.key, e.value]);
      }
      return NullValue.instance;
    default:
      throw VmRuntimeError('undefinedFunction', <String, Object?>{'name': name});
  }
}

Value? getSetProperty(SetValue receiver, String name) {
  switch (name) {
    case 'length':
      return IntValue(receiver.items.length);
    case 'isEmpty':
      return BoolValue(receiver.items.isEmpty);
    case 'isNotEmpty':
      return BoolValue(receiver.items.isNotEmpty);
    default:
      return null;
  }
}

Value callSetMethod(
    SetValue receiver, String name, List<Value> args, InvokeCallback invoke, Dialect dialect) {
  final items = receiver.items;
  switch (name) {
    case 'add':
      return BoolValue(items.add(args[0]));
    case 'remove':
      return BoolValue(items.remove(args[0]));
    case 'contains':
      return BoolValue(items.contains(args[0]));
    case 'clear':
      items.clear();
      return NullValue.instance;
    case 'union':
      final other = args[0] as SetValue;
      return SetValue(LinkedHashSet<Value>.of(items)..addAll(other.items));
    case 'intersection':
      final other = args[0] as SetValue;
      return SetValue(LinkedHashSet<Value>.of(items.where(other.items.contains)));
    case 'difference':
      final other = args[0] as SetValue;
      return SetValue(LinkedHashSet<Value>.of(items.where((e) => !other.items.contains(e))));
    case 'toList':
      return ListValue(List<Value>.of(items));
    default:
      throw VmRuntimeError('undefinedFunction', <String, Object?>{'name': name});
  }
}
