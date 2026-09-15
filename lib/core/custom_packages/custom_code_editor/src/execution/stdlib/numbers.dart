/// Number and math built-ins: abs, floor, ceil, round, pow, sqrt, min, max,
/// parse/tryParse. Also builds the small set of globals every run starts
/// with (`min`, `max`, `int`, `double`, `List`, ...) — the closest thing this
/// engine has to a prelude.
library;

import 'dart:math' as math;

import '../errors/failure.dart';
import '../values/dialect.dart';
import '../values/value.dart';

double _num(Value v) {
  if (v is IntValue) return v.value.toDouble();
  if (v is NumValue) return v.value;
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a number'});
}

Value? getNumberProperty(Value receiver, String name) {
  switch (name) {
    case 'isEven':
      return receiver is IntValue ? BoolValue(receiver.value.isEven) : null;
    case 'isOdd':
      return receiver is IntValue ? BoolValue(receiver.value.isOdd) : null;
    case 'isNegative':
      return BoolValue(_num(receiver) < 0);
    default:
      return null;
  }
}

Value callNumberMethod(Value receiver, String name, List<Value> args, InvokeCallback invoke, Dialect dialect) {
  final n = _num(receiver);
  switch (name) {
    case 'abs':
      return receiver is IntValue ? IntValue(receiver.value.abs()) : NumValue(n.abs());
    case 'floor':
      return IntValue(n.floor());
    case 'ceil':
      return IntValue(n.ceil());
    case 'round':
      return IntValue(n.round());
    case 'toDouble':
      return NumValue(n);
    case 'toInt':
      return IntValue(n.toInt());
    case 'toString':
      return StrValue(receiver is IntValue ? receiver.value.toString() : n.toString());
    case 'compareTo':
      return IntValue(n.compareTo(_num(args[0])));
    case 'clamp':
      return NumValue(n.clamp(_num(args[0]), _num(args[1])).toDouble());
    case 'pow':
      return NumValue(math.pow(n, _num(args[0])).toDouble());
    default:
      throw VmRuntimeError('undefinedFunction', <String, Object?>{'name': name});
  }
}

/// The globals every script run starts with, before the learner's own
/// top-level declarations. Not a full Dart SDK surface — bounded to
/// collections, strings, numbers, and basic math (FR-002e).
Map<String, Value> buildPreludeGlobals() {
  return <String, Value>{
    'min': const NativeFunctionValue('min', 2, _minWrapper),
    'max': const NativeFunctionValue('max', 2, _maxWrapper),
    'sqrt': const NativeFunctionValue('sqrt', 1, _sqrtWrapper),
    'int': NamespaceValue('int', <String, Value>{
      'parse': const NativeFunctionValue('int.parse', 1, _intParse),
      'tryParse': const NativeFunctionValue('int.tryParse', 1, _intTryParse),
    }),
    'double': NamespaceValue('double', <String, Value>{
      'parse': const NativeFunctionValue('double.parse', 1, _doubleParse),
      'tryParse': const NativeFunctionValue('double.tryParse', 1, _doubleTryParse),
    }),
    'List': NamespaceValue('List', <String, Value>{
      'generate': const NativeFunctionValue('List.generate', 2, _listGenerate),
      'filled': const NativeFunctionValue('List.filled', 2, _listFilled),
    }),
  };
}

Value _minWrapper(List<Value> args, InvokeCallback invoke) {
  final a = args[0], b = args[1];
  if (a is IntValue && b is IntValue) return IntValue(a.value < b.value ? a.value : b.value);
  return NumValue(math.min(_num(a), _num(b)));
}

Value _maxWrapper(List<Value> args, InvokeCallback invoke) {
  final a = args[0], b = args[1];
  if (a is IntValue && b is IntValue) return IntValue(a.value > b.value ? a.value : b.value);
  return NumValue(math.max(_num(a), _num(b)));
}

Value _sqrtWrapper(List<Value> args, InvokeCallback invoke) => NumValue(math.sqrt(_num(args[0])));

Value _intParse(List<Value> args, InvokeCallback invoke) {
  final s = (args[0] as StrValue).value;
  final v = int.tryParse(s);
  if (v == null) throw VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'an integer string', 'actual': s});
  return IntValue(v);
}

Value _intTryParse(List<Value> args, InvokeCallback invoke) {
  final v = int.tryParse((args[0] as StrValue).value);
  return v == null ? NullValue.instance : IntValue(v);
}

Value _doubleParse(List<Value> args, InvokeCallback invoke) {
  final s = (args[0] as StrValue).value;
  final v = double.tryParse(s);
  if (v == null) throw VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a number string', 'actual': s});
  return NumValue(v);
}

Value _doubleTryParse(List<Value> args, InvokeCallback invoke) {
  final v = double.tryParse((args[0] as StrValue).value);
  return v == null ? NullValue.instance : NumValue(v);
}

Value _listGenerate(List<Value> args, InvokeCallback invoke) {
  final count = (args[0] as IntValue).value;
  final generator = args[1] as FunctionValue;
  return ListValue(List<Value>.generate(count, (i) => invoke(generator, <Value>[IntValue(i)])));
}

Value _listFilled(List<Value> args, InvokeCallback invoke) {
  final count = (args[0] as IntValue).value;
  final fill = args[1];
  return ListValue(List<Value>.filled(count, fill, growable: true));
}
