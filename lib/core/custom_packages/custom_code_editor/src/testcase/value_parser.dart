import 'parsing_utils.dart';
import 'test_value.dart';

/// Parses a single JSON-like literal into a [TestValue].
TestValue parseValue(String input) {
  final t = input.trim();
  if (t == 'null') return const NullTestValue();
  if (t == 'true' || t == 'false') return BoolTestValue(t == 'true');
  if (t.length >= 2) {
    if (t.startsWith('"') && t.endsWith('"')) {
      return StringTestValue(_unescape(t.substring(1, t.length - 1)));
    }
    if (t.startsWith("'") && t.endsWith("'")) {
      return StringTestValue(t.substring(1, t.length - 1));
    }
  }
  if (t.startsWith('[') && t.endsWith(']')) {
    final inner = t.substring(1, t.length - 1).trim();
    if (inner.isEmpty) return const ListTestValue([]);
    final items = splitTopLevel(inner).map(parseValue).toList(growable: false);
    return ListTestValue(items);
  }
  if (t.startsWith('{') && t.endsWith('}')) {
    final map = _parseMap(t.substring(1, t.length - 1).trim());
    if (map != null) return map;
  }
  final intValue = int.tryParse(t);
  if (intValue != null) return IntTestValue(intValue);
  final doubleValue = double.tryParse(t);
  if (doubleValue != null) return DoubleTestValue(doubleValue);
  return StringTestValue(t);
}

/// Parses a full test-case `input` string of the form
/// `nums=[2,7,11,15], target=9` into a map of argument name -> [TestValue].
Map<String, TestValue> parseTestCaseInput(String input) {
  final result = <String, TestValue>{};
  for (final segment in splitTopLevel(input)) {
    final eq = segment.indexOf('=');
    if (eq <= 0) continue;
    final key = segment.substring(0, eq).trim();
    final value = segment.substring(eq + 1).trim();
    if (key.isEmpty || value.isEmpty) continue;
    result[key] = parseValue(value);
  }
  return result;
}

/// `null` when a part has no `key: value`, so it stays the plain text it was.
MapTestValue? _parseMap(String inner) {
  final entries = <MapEntry<TestValue, TestValue>>[];
  for (final part in splitTopLevel(inner)) {
    final pieces = splitTopLevel(part, delimiter: ':');
    if (pieces.length != 2) return null;
    entries.add(MapEntry(parseValue(pieces[0]), parseValue(pieces[1])));
  }
  return MapTestValue(entries);
}

String _unescape(String s) => s.replaceAll(r'\"', '"').replaceAll(r"\'", "'");
