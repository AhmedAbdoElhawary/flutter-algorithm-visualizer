import 'object_serializer.dart';
import 'test_value.dart';
import 'value_parser.dart';

/// How a problem's output is matched against the expected output.
///
/// Most problems have exactly one correct output, so the canonical strings must
/// match character for character. Some, though, allow any ordering (`subsets`
/// may return its subsets in any order), and grading those by exact string
/// would fail a correct solution purely for the order it happened to produce.
enum OutputComparison {
  /// Character-for-character equality. The default.
  exact('exact'),

  /// The outer list may be in any order; each element's own order still counts
  /// (a permutation's `[1,2,3]` is not its `[3,2,1]`).
  unordered('unordered'),

  /// Every list at every depth may be in any order, e.g. `groupAnagrams`, where
  /// neither the groups nor the words inside a group have a required order.
  unorderedDeep('unordered_deep');

  const OutputComparison(this.key);

  /// The value used in the problem's `comparison` metadata.
  final String key;

  static OutputComparison fromKey(String? key) {
    if (key == null) return OutputComparison.exact;
    for (final mode in values) {
      if (mode.key == key) return mode;
    }
    return OutputComparison.exact;
  }
}

/// Rewrites a canonical output string into the form [mode] compares on, so that
/// two outputs which differ only in an order the problem doesn't fix become
/// identical strings.
///
/// Both the actual and the expected output go through this, so grading stays a
/// plain string comparison.
String normalizeForComparison(String canonical, OutputComparison mode) {
  if (mode == OutputComparison.exact) return canonical;
  final value = testValueToRaw(parseValue(canonical));
  if (value is! List) return canonical;
  return canonicalString(_sorted(value, deep: mode == OutputComparison.unorderedDeep));
}

dynamic _sorted(dynamic value, {required bool deep}) {
  if (value is! List) return value;
  final items = deep ? value.map((e) => _sorted(e, deep: true)).toList() : List<dynamic>.of(value);
  items.sort((a, b) => canonicalString(a).compareTo(canonicalString(b)));
  return items;
}
