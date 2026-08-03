import 'token.dart';

/// Opaque state carried from the end of one line into the start of the
/// next.
///
/// Most tokens (keywords, numbers, operators...) can be recognized by
/// looking at a single line in isolation. A few constructs — block
/// comments, triple-quoted strings — span multiple lines. [LineState]
/// lets a [Tokenizer] remember "I was still inside a block comment when
/// this line ended" without the caller needing to know what that means.
///
/// Implementations should be cheap, immutable value types.
abstract class LineState {
  /// The state a document starts in, before any line has been tokenized.
  const LineState();

  /// A string that uniquely identifies this state for caching purposes.
  ///
  /// Two [LineState]s with the same [cacheKey] must be treated as
  /// interchangeable by [SyntaxHighlighter]'s line cache. The default
  /// implementation uses the runtime type, which is correct for stateless
  /// tokenizers; stateful tokenizers (e.g. ones tracking "inside a block
  /// comment") must override this to also encode that extra state.
  String get cacheKey => runtimeType.toString();
}

/// The trivial [LineState] for tokenizers that never need to carry state
/// across lines (i.e. every line can be tokenized independently).
class StatelessLineState extends LineState {
  const StatelessLineState();
}

/// The result of tokenizing a single line: the tokens found, plus the
/// [LineState] to feed into the *next* line.
class TokenizeResult {
  const TokenizeResult(this.tokens, this.nextState);

  final List<Token> tokens;
  final LineState nextState;
}

/// Turns a single line of source text into a list of [Token]s.
///
/// A [Tokenizer] is deliberately line-oriented (see [LineState]) so that a
/// [SyntaxHighlighter] can re-tokenize only the lines that actually
/// changed, instead of re-scanning the whole document on every keystroke.
abstract class Tokenizer {
  const Tokenizer();

  /// The state to use for the very first line of a document.
  LineState get initialState => const StatelessLineState();

  /// Tokenizes [line] given the [state] carried over from the previous
  /// line, returning the tokens plus the state to carry into the next
  /// line.
  TokenizeResult tokenizeLine(String line, LineState state);
}
