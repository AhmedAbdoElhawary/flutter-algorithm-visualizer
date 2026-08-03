/// Token kinds produced by [Lexer].
///
/// This is a separate, purpose-built lexer from `syntax/dart/dart_highlighter.dart`:
/// the highlighter's tokenizer is optimized for per-line, cache-friendly
/// coloring, while this one produces a flat, whole-source token stream
/// with accurate line numbers, which is what a parser needs.
enum TokKind {
  intLiteral,
  doubleLiteral,
  stringLiteral,
  identifier,
  keyword,
  symbol,
  eof,
}

const Set<String> kKeywords = <String>{
  'var', 'final', 'const', 'int', 'double', 'String', 'bool', 'num',
  'dynamic', 'void', 'List', 'if', 'else', 'while', 'for', 'do', 'return',
  'break', 'continue', 'true', 'false', 'null', 'in',
};

/// A single lexical token with source-line information, used for both
/// parse errors and runtime error reporting.
class Tok {
  const Tok(this.kind, this.text, this.line, [this.value]);

  final TokKind kind;
  final String text;

  /// 1-indexed source line this token starts on.
  final int line;

  /// Parsed literal value for [TokKind.intLiteral]/[TokKind.doubleLiteral]
  /// (an [int] or [double]), or the unescaped contents for
  /// [TokKind.stringLiteral] (a [String], still containing raw `$`
  /// interpolation markers for the parser to split out).
  final Object? value;

  @override
  String toString() => 'Tok($kind, "$text", line $line)';
}

/// Thrown when the lexer encounters source text it cannot tokenize.
class LexError implements Exception {
  LexError(this.message, this.line);
  final String message;
  final int line;
}

/// Turns Dart-subset source text into a flat list of [Tok]s (plus a
/// trailing EOF token), tracking line numbers as it goes.
class Lexer {
  Lexer(this.source);

  final String source;

  static const List<String> _multiCharSymbols = <String>[
    '=>', '==', '!=', '<=', '>=', '&&', '||', '++', '--', '+=', '-=', '*=',
    '/=', '~/',
  ];
  static const String _singleCharSymbols = '+-*/%=<>!(){}[],;.?:';

  List<Tok> tokenize() {
    final List<Tok> tokens = <Tok>[];
    int i = 0;
    int line = 1;

    while (i < source.length) {
      final String ch = source[i];

      if (ch == '\n') {
        line++;
        i++;
        continue;
      }
      if (ch == ' ' || ch == '\t' || ch == '\r') {
        i++;
        continue;
      }

      // Line comment.
      if (ch == '/' && i + 1 < source.length && source[i + 1] == '/') {
        while (i < source.length && source[i] != '\n') {
          i++;
        }
        continue;
      }

      // Block comment (supports nesting, like real Dart).
      if (ch == '/' && i + 1 < source.length && source[i + 1] == '*') {
        final int startLine = line;
        int depth = 1;
        i += 2;
        while (i < source.length && depth > 0) {
          if (source[i] == '\n') line++;
          if (i + 1 < source.length && source[i] == '/' && source[i + 1] == '*') {
            depth++;
            i += 2;
            continue;
          }
          if (i + 1 < source.length && source[i] == '*' && source[i + 1] == '/') {
            depth--;
            i += 2;
            continue;
          }
          i++;
        }
        if (depth > 0) {
          throw LexError('Unterminated block comment', startLine);
        }
        continue;
      }

      // String literal (single or double quoted; single-line only).
      if (ch == '"' || ch == "'") {
        final int startLine = line;
        final String quote = ch;
        final StringBuffer buf = StringBuffer();
        i++;
        while (i < source.length && source[i] != quote) {
          if (source[i] == '\n') {
            throw LexError('Unterminated string literal', startLine);
          }
          if (source[i] == r'\' && i + 1 < source.length) {
            final String next = source[i + 1];
            switch (next) {
              case 'n':
                buf.write('\n');
                break;
              case 't':
                buf.write('\t');
                break;
              case r'$':
                buf.write(r'$');
                break;
              case r'\':
                buf.write(r'\');
                break;
              case '"':
                buf.write('"');
                break;
              case "'":
                buf.write("'");
                break;
              default:
                buf.write(next);
            }
            i += 2;
            continue;
          }
          buf.write(source[i]);
          i++;
        }
        if (i >= source.length) {
          throw LexError('Unterminated string literal', startLine);
        }
        i++; // closing quote
        tokens.add(Tok(TokKind.stringLiteral, buf.toString(), startLine, buf.toString()));
        continue;
      }

      // Numbers.
      if (_isDigit(ch)) {
        final int startLine = line;
        final int start = i;
        bool isDouble = false;
        while (i < source.length && _isDigit(source[i])) {
          i++;
        }
        if (i < source.length &&
            source[i] == '.' &&
            i + 1 < source.length &&
            _isDigit(source[i + 1])) {
          isDouble = true;
          i++;
          while (i < source.length && _isDigit(source[i])) {
            i++;
          }
        }
        final String text = source.substring(start, i);
        if (isDouble) {
          tokens.add(Tok(TokKind.doubleLiteral, text, startLine, double.parse(text)));
        } else {
          tokens.add(Tok(TokKind.intLiteral, text, startLine, int.parse(text)));
        }
        continue;
      }

      // Identifiers / keywords.
      if (_isIdentStart(ch)) {
        final int startLine = line;
        final int start = i;
        while (i < source.length && _isIdentPart(source[i])) {
          i++;
        }
        final String text = source.substring(start, i);
        tokens.add(Tok(
          kKeywords.contains(text) ? TokKind.keyword : TokKind.identifier,
          text,
          startLine,
        ));
        continue;
      }

      // Multi-character symbols (longest match first).
      final String twoOrMore = source.substring(
        i,
        i + 2 <= source.length ? i + 2 : source.length,
      );
      final String? matchedMulti = _multiCharSymbols
          .where((String s) => twoOrMore.startsWith(s))
          .fold<String?>(null, (String? best, String s) =>
              best == null || s.length > best.length ? s : best);
      if (matchedMulti != null) {
        tokens.add(Tok(TokKind.symbol, matchedMulti, line));
        i += matchedMulti.length;
        continue;
      }

      // Single-character symbols.
      if (_singleCharSymbols.contains(ch)) {
        tokens.add(Tok(TokKind.symbol, ch, line));
        i++;
        continue;
      }

      throw LexError('Unexpected character "$ch"', line);
    }

    tokens.add(Tok(TokKind.eof, '', line));
    return tokens;
  }

  static bool _isDigit(String c) => c.compareTo('0') >= 0 && c.compareTo('9') <= 0;
  static bool _isIdentStart(String c) =>
      RegExp(r'[A-Za-z_$]').hasMatch(c);
  static bool _isIdentPart(String c) => RegExp(r'[A-Za-z0-9_$]').hasMatch(c);
}
