import '../token.dart';
import '../token_type.dart';
import '../tokenizer.dart';

/// [LineState] for [DartTokenizer]: whether the line starts already inside
/// an unterminated `/* ... */` block comment.
class _DartLineState extends LineState {
  const _DartLineState({this.inBlockComment = false});

  final bool inBlockComment;

  @override
  String get cacheKey => 'dart:$inBlockComment';
}

/// A small, dependency-free tokenizer for Dart source.
///
/// This is intentionally a "good enough for editor coloring" lexer, not a
/// full Dart parser: it does not build an AST and does not need to, since
/// the editor only cares about *coloring*, not semantics.
class DartTokenizer extends Tokenizer {
  const DartTokenizer();

  static const Set<String> _keywords = <String>{
    'abstract',
    'as',
    'assert',
    'async',
    'await',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'covariant',
    'default',
    'deferred',
    'do',
    'dynamic',
    'else',
    'enum',
    'export',
    'extends',
    'extension',
    'external',
    'factory',
    'false',
    'final',
    'finally',
    'for',
    'Function',
    'get',
    'hide',
    'if',
    'implements',
    'import',
    'in',
    'interface',
    'is',
    'late',
    'library',
    'mixin',
    'new',
    'null',
    'on',
    'operator',
    'part',
    'required',
    'rethrow',
    'return',
    'set',
    'show',
    'static',
    'super',
    'switch',
    'sync',
    'this',
    'throw',
    'true',
    'try',
    'typedef',
    'var',
    'void',
    'while',
    'with',
    'yield',
  };

  static const Set<String> _builtinTypes = <String>{
    'int',
    'double',
    'num',
    'String',
    'bool',
    'List',
    'Map',
    'Set',
    'Object',
    'Never',
    'Iterable',
    'Future',
    'Stream',
  };

  static final RegExp _identifierStart = RegExp(r'[A-Za-z_$]');
  static final RegExp _identifierPart = RegExp(r'[A-Za-z0-9_$]');
  static final RegExp _digit = RegExp(r'[0-9]');
  static const String _operatorChars = '+-*/%=!<>&|^~?:';
  static const String _punctuationChars = r'(){}[],.;';

  @override
  LineState get initialState => const _DartLineState();

  @override
  TokenizeResult tokenizeLine(String line, LineState state) {
    final bool startsInBlockComment = state is _DartLineState && state.inBlockComment;
    final List<Token> tokens = <Token>[];
    int i = 0;
    bool inBlockComment = startsInBlockComment;

    if (inBlockComment) {
      final int end = line.indexOf('*/');
      if (end == -1) {
        tokens.add(Token(
          type: TokenType.comment,
          text: line,
          start: 0,
          end: line.length,
        ));
        return TokenizeResult(
          tokens,
          const _DartLineState(inBlockComment: true),
        );
      } else {
        tokens.add(Token(
          type: TokenType.comment,
          text: line.substring(0, end + 2),
          start: 0,
          end: end + 2,
        ));
        i = end + 2;
        inBlockComment = false;
      }
    }

    while (i < line.length) {
      final String ch = line[i];

      // Whitespace: skip, no token needed.
      if (ch == ' ' || ch == '\t') {
        i++;
        continue;
      }

      // Line comment.
      if (ch == '/' && i + 1 < line.length && line[i + 1] == '/') {
        tokens.add(Token(
          type: TokenType.comment,
          text: line.substring(i),
          start: i,
          end: line.length,
        ));
        i = line.length;
        break;
      }

      // Block comment start.
      if (ch == '/' && i + 1 < line.length && line[i + 1] == '*') {
        final int end = line.indexOf('*/', i + 2);
        if (end == -1) {
          tokens.add(Token(
            type: TokenType.comment,
            text: line.substring(i),
            start: i,
            end: line.length,
          ));
          return TokenizeResult(
            tokens,
            const _DartLineState(inBlockComment: true),
          );
        } else {
          tokens.add(Token(
            type: TokenType.comment,
            text: line.substring(i, end + 2),
            start: i,
            end: end + 2,
          ));
          i = end + 2;
          continue;
        }
      }

      // String literals: '...' or "..." with escape support. Doesn't
      // attempt to model Dart's triple-quoted / raw string edge cases —
      // acceptable for editor coloring purposes.
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
            (_digit.hasMatch(line[i]) ||
                line[i] == '.' ||
                line[i] == 'x' ||
                RegExp(r'[A-Fa-f]').hasMatch(line[i]))) {
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
        } else if (_builtinTypes.contains(word)) {
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

      // Anything else (unicode identifiers, stray symbols): emit as plain.
      tokens.add(
        Token(type: TokenType.plain, text: ch, start: i, end: i + 1),
      );
      i++;
    }

    return TokenizeResult(tokens, const _DartLineState());
  }
}
