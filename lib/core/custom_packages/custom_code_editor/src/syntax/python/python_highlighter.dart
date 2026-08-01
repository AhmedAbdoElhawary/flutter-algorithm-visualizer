import '../token.dart';
import '../token_type.dart';
import '../tokenizer.dart';

/// [LineState] for [PythonTokenizer]: whether the line starts inside an
/// unterminated triple-quoted string, and with which quote style.
class _PythonLineState extends LineState {
  const _PythonLineState({this.tripleQuote});

  /// `'''`, `"""`, or null if not currently inside one.
  final String? tripleQuote;

  @override
  String get cacheKey => 'py:${tripleQuote ?? '-'}';
}

/// A small, dependency-free tokenizer for Python source.
///
/// Like [DartTokenizer], this favors a fast, "good enough for coloring"
/// hand-rolled lexer over a full grammar implementation.
class PythonTokenizer extends Tokenizer {
  const PythonTokenizer();

  static const Set<String> _keywords = <String>{
    'and', 'as', 'assert', 'async', 'await', 'break', 'class', 'continue',
    'def', 'del', 'elif', 'else', 'except', 'finally', 'for', 'from',
    'global', 'if', 'import', 'in', 'is', 'lambda', 'nonlocal', 'not', 'or',
    'pass', 'raise', 'return', 'try', 'while', 'with', 'yield',
  };

  static const Set<String> _builtins = <String>{
    'True', 'False', 'None', 'int', 'float', 'str', 'bool', 'list', 'dict',
    'set', 'tuple', 'object', 'self', 'cls', 'print', 'len', 'range',
  };

  static final RegExp _identifierStart = RegExp(r'[A-Za-z_]');
  static final RegExp _identifierPart = RegExp(r'[A-Za-z0-9_]');
  static final RegExp _digit = RegExp(r'[0-9]');
  static const String _operatorChars = '+-*/%=!<>&|^~';
  static const String _punctuationChars = '(){}[],.:;';

  @override
  LineState get initialState => const _PythonLineState();

  @override
  TokenizeResult tokenizeLine(String line, LineState state) {
    final String? openTriple =
        state is _PythonLineState ? state.tripleQuote : null;
    final List<Token> tokens = <Token>[];
    int i = 0;

    if (openTriple != null) {
      final int end = line.indexOf(openTriple);
      if (end == -1) {
        tokens.add(Token(
          type: TokenType.string,
          text: line,
          start: 0,
          end: line.length,
        ));
        return TokenizeResult(
          tokens,
          _PythonLineState(tripleQuote: openTriple),
        );
      } else {
        tokens.add(Token(
          type: TokenType.string,
          text: line.substring(0, end + 3),
          start: 0,
          end: end + 3,
        ));
        i = end + 3;
      }
    }

    while (i < line.length) {
      final String ch = line[i];

      if (ch == ' ' || ch == '\t') {
        i++;
        continue;
      }

      // Comment runs to end of line.
      if (ch == '#') {
        tokens.add(Token(
          type: TokenType.comment,
          text: line.substring(i),
          start: i,
          end: line.length,
        ));
        break;
      }

      // Triple-quoted strings.
      if ((ch == '"' || ch == "'") &&
          i + 2 < line.length &&
          line[i + 1] == ch &&
          line[i + 2] == ch) {
        final String quote = ch * 3;
        final int start = i;
        final int end = line.indexOf(quote, i + 3);
        if (end == -1) {
          tokens.add(Token(
            type: TokenType.string,
            text: line.substring(start),
            start: start,
            end: line.length,
          ));
          return TokenizeResult(
            tokens,
            _PythonLineState(tripleQuote: quote),
          );
        } else {
          tokens.add(Token(
            type: TokenType.string,
            text: line.substring(start, end + 3),
            start: start,
            end: end + 3,
          ));
          i = end + 3;
          continue;
        }
      }

      // Regular string literals.
      if (ch == '"' || ch == "'") {
        final int start = i;
        final String quote = ch;
        i++;
        while (i < line.length) {
          if (line[i] == r'\' && i + 1 < line.length) {
            i += 2;
            continue;
          }
          if (line[i] == quote) {
            i++;
            break;
          }
          i++;
        }
        tokens.add(Token(
          type: TokenType.string,
          text: line.substring(start, i),
          start: start,
          end: i,
        ));
        continue;
      }

      // Numbers.
      if (_digit.hasMatch(ch)) {
        final int start = i;
        while (i < line.length &&
            (_digit.hasMatch(line[i]) || line[i] == '.')) {
          i++;
        }
        tokens.add(Token(
          type: TokenType.number,
          text: line.substring(start, i),
          start: start,
          end: i,
        ));
        continue;
      }

      // Identifiers / keywords / builtins.
      if (_identifierStart.hasMatch(ch)) {
        final int start = i;
        while (i < line.length && _identifierPart.hasMatch(line[i])) {
          i++;
        }
        final String word = line.substring(start, i);
        final TokenType type;
        if (_keywords.contains(word)) {
          type = TokenType.keyword;
        } else if (_builtins.contains(word)) {
          type = TokenType.builtin;
        } else {
          type = TokenType.identifier;
        }
        tokens.add(Token(type: type, text: word, start: start, end: i));
        continue;
      }

      // Operators.
      if (_operatorChars.contains(ch)) {
        final int start = i;
        while (i < line.length && _operatorChars.contains(line[i])) {
          i++;
        }
        tokens.add(Token(
          type: TokenType.operator,
          text: line.substring(start, i),
          start: start,
          end: i,
        ));
        continue;
      }

      // Punctuation.
      if (_punctuationChars.contains(ch)) {
        tokens.add(Token(
          type: TokenType.punctuation,
          text: ch,
          start: i,
          end: i + 1,
        ));
        i++;
        continue;
      }

      tokens.add(
        Token(type: TokenType.plain, text: ch, start: i, end: i + 1),
      );
      i++;
    }

    return TokenizeResult(tokens, const _PythonLineState());
  }
}
