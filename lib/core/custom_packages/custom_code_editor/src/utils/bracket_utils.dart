/// Pure helpers for automatic bracket / quote pairing. Deliberately free
/// of `TextEditingController` concerns so they're trivial to unit test.
class BracketUtils {
  const BracketUtils._();

  /// Maps an opening character to its matching closing character.
  static const Map<String, String> pairs = <String, String>{
    '(': ')',
    '[': ']',
    '{': '}',
    '<': '>',
    '"': '"',
    "'": "'",
  };

  /// The set of characters that open a pair (includes quotes).
  static Set<String> get openers => pairs.keys.toSet();

  /// The set of characters that close a pair (includes quotes).
  static Set<String> get closers => pairs.values.toSet();

  /// Quote characters are both "openers" and "closers" of themselves, so
  /// they need special type-over handling.
  static const Set<String> quotes = <String>{'"', "'"};

  static bool isOpener(String char) => openers.contains(char);

  static bool isCloser(String char) => closers.contains(char);

  static bool isQuote(String char) => char == '"' || char == "'";

  /// Whether [open] and [close] form a matching pair.
  static bool isMatchingPair(String open, String close) =>
      pairs[open] == close;

  /// The closing character that should be auto-inserted for [opener], or
  /// null if [opener] isn't a recognized opening character.
  static String? closingFor(String opener) => pairs[opener];
}
