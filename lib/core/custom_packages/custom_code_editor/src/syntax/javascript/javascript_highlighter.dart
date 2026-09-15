import '../token.dart';
import '../token_type.dart';
import '../tokenizer.dart';

/// [LineState] for [JavascriptTokenizer]: whether the line starts inside an
/// unterminated `/* */` comment or an unterminated backtick template
/// literal. Both are the constructs that can run past the end of a line.
class _JavascriptLineState extends LineState {
  const _JavascriptLineState({this.inBlockComment = false, this.inTemplate = false});

  final bool inBlockComment;
  final bool inTemplate;

  @override
  String get cacheKey => 'js:${inBlockComment ? 'c' : '-'}${inTemplate ? 't' : '-'}';
}

/// A small, dependency-free tokenizer for JavaScript source.
///
/// Like the Dart and Python ones, this favours a fast, good-enough-for-
/// colouring hand-rolled lexer over a full grammar. It deliberately does not
/// try to tell a regular expression literal from a division sign, which
/// needs real parser context — a `/` is always coloured as an operator.
class JavascriptTokenizer extends Tokenizer {
  const JavascriptTokenizer();

  static const Set<String> _keywords = <String>{
    'async', 'await', 'break', 'case', 'catch', 'class', 'const', 'continue', //
    'debugger', 'default', 'delete', 'do', 'else', 'export', 'extends',
    'finally', 'for', 'function', 'if', 'import', 'in', 'instanceof', 'let',
    'new', 'of', 'return', 'static', 'super', 'switch', 'this', 'throw',
    'try', 'typeof', 'var', 'void', 'while', 'with', 'yield', 'get', 'set',
  };

  static const Set<String> _builtins = <String>{
    'true', 'false', 'null', 'undefined', 'NaN', 'Infinity', //
    'Array', 'Boolean', 'Date', 'Error', 'JSON', 'Map', 'Math', 'Number',
    'Object', 'Promise', 'RegExp', 'Set', 'String', 'Symbol',
    'console', 'parseInt', 'parseFloat', 'isNaN',
  };

  static final RegExp _identifierStart = RegExp(r'[A-Za-z_$]');
  static final RegExp _identifierPart = RegExp(r'[A-Za-z0-9_$]');
  static final RegExp _digit = RegExp(r'[0-9]');
  static const String _operatorChars = '+-*/%=!<>&|^~?';
  static const String _punctuationChars = '(){}[],.:;';

  @override
  LineState get initialState => const _JavascriptLineState();

  @override
  TokenizeResult tokenizeLine(String line, LineState state) {
    final carried = state is _JavascriptLineState ? state : const _JavascriptLineState();
    final tokens = <Token>[];
    var i = 0;

    if (carried.inBlockComment) {
      final end = line.indexOf('*/');
      if (end == -1) {
        tokens.add(Token(type: TokenType.comment, text: line, start: 0, end: line.length));
        return TokenizeResult(tokens, const _JavascriptLineState(inBlockComment: true));
      }
      tokens.add(Token(type: TokenType.comment, text: line.substring(0, end + 2), start: 0, end: end + 2));
      i = end + 2;
    } else if (carried.inTemplate) {
      final end = _endOfTemplate(line, 0);
      if (end == -1) {
        tokens.add(Token(type: TokenType.string, text: line, start: 0, end: line.length));
        return TokenizeResult(tokens, const _JavascriptLineState(inTemplate: true));
      }
      tokens.add(Token(type: TokenType.string, text: line.substring(0, end + 1), start: 0, end: end + 1));
      i = end + 1;
    }

    while (i < line.length) {
      final ch = line[i];

      if (ch == ' ' || ch == '\t') {
        i++;
        continue;
      }

      if (ch == '/' && i + 1 < line.length && line[i + 1] == '/') {
        tokens.add(Token(type: TokenType.comment, text: line.substring(i), start: i, end: line.length));
        break;
      }

      if (ch == '/' && i + 1 < line.length && line[i + 1] == '*') {
        final end = line.indexOf('*/', i + 2);
        if (end == -1) {
          tokens.add(Token(type: TokenType.comment, text: line.substring(i), start: i, end: line.length));
          return TokenizeResult(tokens, const _JavascriptLineState(inBlockComment: true));
        }
        tokens
            .add(Token(type: TokenType.comment, text: line.substring(i, end + 2), start: i, end: end + 2));
        i = end + 2;
        continue;
      }

      if (ch == '`') {
        final start = i;
        final end = _endOfTemplate(line, i + 1);
        if (end == -1) {
          tokens.add(
              Token(type: TokenType.string, text: line.substring(start), start: start, end: line.length));
          return TokenizeResult(tokens, const _JavascriptLineState(inTemplate: true));
        }
        tokens.add(
            Token(type: TokenType.string, text: line.substring(start, end + 1), start: start, end: end + 1));
        i = end + 1;
        continue;
      }

      if (ch == '"' || ch == "'") {
        final start = i;
        final quote = ch;
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
        tokens.add(Token(type: TokenType.string, text: line.substring(start, i), start: start, end: i));
        continue;
      }

      if (_digit.hasMatch(ch)) {
        final start = i;
        while (i < line.length && (_digit.hasMatch(line[i]) || line[i] == '.' || line[i] == '_')) {
          i++;
        }
        tokens.add(Token(type: TokenType.number, text: line.substring(start, i), start: start, end: i));
        continue;
      }

      if (_identifierStart.hasMatch(ch)) {
        final start = i;
        while (i < line.length && _identifierPart.hasMatch(line[i])) {
          i++;
        }
        final word = line.substring(start, i);
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

      if (_operatorChars.contains(ch)) {
        final start = i;
        while (i < line.length && _operatorChars.contains(line[i])) {
          i++;
        }
        tokens.add(Token(type: TokenType.operator, text: line.substring(start, i), start: start, end: i));
        continue;
      }

      if (_punctuationChars.contains(ch)) {
        tokens.add(Token(type: TokenType.punctuation, text: ch, start: i, end: i + 1));
        i++;
        continue;
      }

      tokens.add(Token(type: TokenType.plain, text: ch, start: i, end: i + 1));
      i++;
    }

    return TokenizeResult(tokens, const _JavascriptLineState());
  }

  /// The index of the backtick closing a template literal that starts at
  /// [from], or -1 when it runs past the end of the line. Escapes are
  /// skipped so that `` \` `` does not end the literal.
  int _endOfTemplate(String line, int from) {
    var i = from;
    while (i < line.length) {
      if (line[i] == r'\' && i + 1 < line.length) {
        i += 2;
        continue;
      }
      if (line[i] == '`') return i;
      i++;
    }
    return -1;
  }
}
