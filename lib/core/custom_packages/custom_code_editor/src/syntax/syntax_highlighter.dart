import 'token.dart';
import 'tokenizer.dart';

/// Turns a full document (as a list of lines) into per-line token lists,
/// re-using cached work as much as possible.
///
/// This class is the piece that keeps the editor fast on large files: it
/// never re-tokenizes the whole document on every keystroke. Instead it:
///
/// 1. Finds the first line that actually changed since the last call.
/// 2. Re-tokenizes forward from there, using a small LRU-ish cache keyed by
///    "(carried-over state, line text)" so that unchanged lines that were
///    already seen (e.g. blank lines, `}` lines) are free.
/// 3. Stops as soon as the carried-over [LineState] converges back to what
///    it was before the edit, and re-uses the previously computed tokens
///    for every line after that point.
///
/// The UI layer never talks to this class directly for coloring — see
/// `CodeSpanBuilder` in `rendering/code_painter.dart`, which turns the
/// [Token] lists this class produces into a `TextSpan` using a theme.
class SyntaxHighlighter {
  SyntaxHighlighter(this.tokenizer);

  /// The language-specific tokenizer this highlighter delegates to.
  final Tokenizer tokenizer;

  /// Cache of individual-line tokenization results, keyed by
  /// "stateKey\u0000lineText" so the same line text tokenizes differently
  /// depending on whether e.g. it starts inside a block comment.
  final Map<String, TokenizeResult> _cache = <String, TokenizeResult>{};

  /// A crude cap on cache growth. When exceeded we simply drop the whole
  /// cache rather than implementing a full LRU — large files with huge
  /// amounts of unique lines are rare, and this keeps the class simple.
  static const int _maxCacheEntries = 6000;

  List<String> _lastLines = const <String>[];
  List<List<Token>> _lastTokens = const <List<Token>>[];
  List<LineState> _lastEndStates = const <LineState>[];

  /// Computes the token lists for [lines], one entry per line.
  ///
  /// Safe to call on every text change; unaffected lines are served from
  /// the previous result without re-tokenizing.
  List<List<Token>> highlight(List<String> lines) {
    final int firstDiff = _firstDifferingLine(lines);
    if (firstDiff == -1) {
      // Nothing changed at all.
      return _lastTokens;
    }

    final bool sameLineCount = lines.length == _lastLines.length;

    final List<List<Token>> newTokens = List<List<Token>>.filled(
      lines.length,
      const <Token>[],
      growable: false,
    );
    final List<LineState> newEndStates = List<LineState>.filled(
      lines.length,
      tokenizer.initialState,
      growable: false,
    );

    // Lines before the first diff are guaranteed unaffected.
    for (int i = 0; i < firstDiff; i++) {
      newTokens[i] = _lastTokens[i];
      newEndStates[i] = _lastEndStates[i];
    }

    LineState state = firstDiff == 0 ? tokenizer.initialState : newEndStates[firstDiff - 1];

    int i = firstDiff;
    for (; i < lines.length; i++) {
      final TokenizeResult result = _tokenizeCached(lines[i], state);
      newTokens[i] = result.tokens;
      newEndStates[i] = result.nextState;
      state = result.nextState;

      // Early-exit: once we're past the directly-edited line, if this
      // line's text is unchanged from before AND the carried-over state
      // has converged back to what it used to be, everything after this
      // point is guaranteed identical to the previous run.
      final bool pastEditedLine = i > firstDiff;
      if (pastEditedLine &&
          sameLineCount &&
          i < _lastLines.length &&
          lines[i] == _lastLines[i] &&
          _sameState(result.nextState, _lastEndStates[i])) {
        i++;
        break;
      }
    }

    // Copy the tail from the previous computation when we stopped early
    // or when trailing lines beyond the diff were never touched (only
    // possible when line counts match).
    if (sameLineCount) {
      for (; i < lines.length; i++) {
        newTokens[i] = _lastTokens[i];
        newEndStates[i] = _lastEndStates[i];
      }
    }

    _lastLines = lines;
    _lastTokens = newTokens;
    _lastEndStates = newEndStates;
    return newTokens;
  }

  /// Drops all cached state. Call this if you swap the [tokenizer] /
  /// language at runtime.
  void reset() {
    _cache.clear();
    _lastLines = const <String>[];
    _lastTokens = const <List<Token>>[];
    _lastEndStates = const <LineState>[];
  }

  TokenizeResult _tokenizeCached(String line, LineState state) {
    final String key = '${state.cacheKey}\u0000$line';
    final TokenizeResult? cached = _cache[key];
    if (cached != null) return cached;

    if (_cache.length >= _maxCacheEntries) {
      _cache.clear();
    }
    final TokenizeResult result = tokenizer.tokenizeLine(line, state);
    _cache[key] = result;
    return result;
  }

  bool _sameState(LineState a, LineState b) => a.cacheKey == b.cacheKey;

  int _firstDifferingLine(List<String> lines) {
    final int minLen = lines.length < _lastLines.length ? lines.length : _lastLines.length;
    for (int i = 0; i < minLen; i++) {
      if (lines[i] != _lastLines[i]) return i;
    }
    if (lines.length != _lastLines.length) return minLen;
    return -1;
  }
}
