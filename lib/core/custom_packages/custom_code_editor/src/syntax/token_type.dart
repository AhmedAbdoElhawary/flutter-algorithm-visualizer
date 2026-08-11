/// The semantic category of a [Token].
///
/// This enum is intentionally small and language-agnostic. Every language
/// highlighter (Dart, Python, ...) maps its own grammar onto this fixed set
/// of categories so that the editor's UI layer never needs to know anything
/// language-specific — it only needs to know how to color a [TokenType].
enum TokenType {
  /// Language keywords (`if`, `class`, `def`, `return`, ...).
  keyword,

  /// String literals, including multi-line / triple-quoted strings.
  string,

  /// Numeric literals (integers, doubles, hex, etc).
  /// 0, 1, 23, 0.5...
  number,

  /// Single-line and multi-line comments.
  comment,

  /// Identifiers: variable names, function names, type names.
  identifier,

  /// Operators such as `+`, `-`, `==`, `=>`, `&&`.
  operator,

  /// Punctuation: brackets, commas, semicolons, dots.
  /// { } ( ) [ ] ; , .
  punctuation,

  /// Built-in / well-known type or constant names (`int`, `True`, `null`).
  /// Built-in objects/functions
  /// Math, console, Array, String...
  builtin,

  /// Anything that does not fall into one of the categories above.
  /// Plain text
  plain,
}
