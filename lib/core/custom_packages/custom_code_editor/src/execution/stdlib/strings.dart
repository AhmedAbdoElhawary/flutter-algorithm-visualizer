/// String built-ins: split, substring, indexOf, replace, trim, case
/// conversion, padding, codeUnitAt, comparison.
library;

import '../errors/failure.dart';
import '../values/dialect.dart';
import '../values/value.dart';

Value? getStringProperty(String s, String name, Dialect dialect) {
  switch (name) {
    case 'length':
      return IntValue(s.length);
    case 'isEmpty':
      return BoolValue(s.isEmpty);
    case 'isNotEmpty':
      return BoolValue(s.isNotEmpty);
    default:
      return null;
  }
}

Value callStringMethod(String s, String name, List<Value> args, InvokeCallback invoke, Dialect dialect) {
  switch (name) {
    case 'split':
      final sep = (args[0] as StrValue).value;
      return ListValue(s.split(sep).map<Value>(StrValue.new).toList());
    case 'substring':
      final start = (args[0] as IntValue).value;
      final end = args.length > 1 ? (args[1] as IntValue).value : s.length;
      if (start < 0 || end > s.length || start > end) {
        throw VmRuntimeError('indexOutOfRange', <String, Object?>{'index': start, 'length': s.length});
      }
      return StrValue(s.substring(start, end));
    case 'indexOf':
      return IntValue(s.indexOf((args[0] as StrValue).value));
    case 'lastIndexOf':
      return IntValue(s.lastIndexOf((args[0] as StrValue).value));
    case 'replaceAll':
    case 'replace':
      return StrValue(s.replaceAll((args[0] as StrValue).value, (args[1] as StrValue).value));
    case 'replaceFirst':
      return StrValue(s.replaceFirst((args[0] as StrValue).value, (args[1] as StrValue).value));
    case 'trim':
      return StrValue(s.trim());
    case 'trimLeft':
      return StrValue(s.trimLeft());
    case 'trimRight':
      return StrValue(s.trimRight());
    case 'toUpperCase':
      return StrValue(s.toUpperCase());
    case 'toLowerCase':
      return StrValue(s.toLowerCase());
    case 'padLeft':
      final width = (args[0] as IntValue).value;
      final pad = args.length > 1 ? (args[1] as StrValue).value : ' ';
      return StrValue(s.padLeft(width, pad));
    case 'padRight':
      final width = (args[0] as IntValue).value;
      final pad = args.length > 1 ? (args[1] as StrValue).value : ' ';
      return StrValue(s.padRight(width, pad));
    case 'codeUnitAt':
      final idx = (args[0] as IntValue).value;
      if (idx < 0 || idx >= s.length) {
        throw VmRuntimeError('indexOutOfRange', <String, Object?>{'index': idx, 'length': s.length});
      }
      return IntValue(s.codeUnitAt(idx));
    case 'compareTo':
      return IntValue(s.compareTo((args[0] as StrValue).value));
    case 'contains':
      return BoolValue(s.contains((args[0] as StrValue).value));
    case 'startsWith':
      return BoolValue(s.startsWith((args[0] as StrValue).value));
    case 'endsWith':
      return BoolValue(s.endsWith((args[0] as StrValue).value));
    case 'toString':
      return StrValue(s);
    case 'toList':
      return ListValue(s.split('').map<Value>(StrValue.new).toList());
    case 'toInt':
      final v = int.tryParse(s);
      if (v == null) {
        throw VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'an integer string', 'actual': s});
      }
      return IntValue(v);
    case '*':
      final n = (args[0] as IntValue).value;
      return StrValue(s * n);
    default:
      throw VmRuntimeError('undefinedFunction', <String, Object?>{'name': name});
  }
}
