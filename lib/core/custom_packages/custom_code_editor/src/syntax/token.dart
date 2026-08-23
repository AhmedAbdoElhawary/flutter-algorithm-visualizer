import 'token_type.dart';

/// A single lexical unit produced by a [Tokenizer].
///
/// A [Token] always refers to a slice of a *single line* of source text
/// (`start`/`end` are column offsets within that line, not the whole
/// document). Keeping tokens line-scoped is what makes incremental
/// re-highlighting possible: when a line changes, only that line's tokens
/// need to be recomputed.
class Token {
  const Token({
    required this.type,
    required this.text,
    required this.start,
    required this.end,
  });

  /// The semantic category of this token.
  final TokenType type;

  /// The raw source text covered by this token.
  final String text;

  /// Inclusive start column offset within the line.
  final int start;

  /// Exclusive end column offset within the line.
  final int end;

  @override
  String toString() => 'Token($type, "$text", $start-$end)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Token &&
          other.type == type &&
          other.text == text &&
          other.start == start &&
          other.end == end);

  @override
  int get hashCode => Object.hash(type, text, start, end);
}
