/// A lexer for the supported JavaScript subset.
///
/// The notable job here is **automatic semicolon insertion**. Rather than
/// inventing semicolon tokens — which needs the parser's context to get
/// right, and gets it wrong in exactly the cases that matter — this lexer
/// records, on every token, whether a line break came before it. The parser
/// then treats "a newline came before the next token" as a statement
/// terminator wherever it would accept a `;`. That is ASI as the standard
/// actually defines it, and it keeps the rule in one readable place
/// (`javascript_parser.dart`'s `_consumeSemicolon`).
library;

import '../../errors/failure.dart';

enum JsTokenType {
  name,
  keyword,
  numberLiteral,
  stringLiteral,

  /// A backtick template literal; [JsToken.literal] holds its parts.
  templateLiteral,
  op,
  eof,
}

/// One `${...}` hole inside a template literal: the raw, not-yet-parsed
/// JavaScript source of the embedded expression.
class JsInterpolation {
  const JsInterpolation(this.source, this.line);
  final String source;
  final int line;
}

class JsToken {
  const JsToken({
    required this.type,
    required this.lexeme,
    required this.line,
    required this.newlineBefore,
    this.literal,
  });

  final JsTokenType type;
  final String lexeme;
  final int line;

  /// Whether a line break separates this token from the previous one — the
  /// single fact automatic semicolon insertion turns on.
  final bool newlineBefore;

  /// `num` for numeric literals, `String` for string literals, and
  /// `List<Object>` (alternating `String` and [JsInterpolation]) for template
  /// literals.
  final Object? literal;

  @override
  String toString() => '$type(${literal ?? lexeme}) @$line';
}

const Set<String> jsKeywords = <String>{
  'break', 'case', 'catch', 'class', 'const', 'continue', 'debugger', //
  'default', 'delete', 'do', 'else', 'export', 'extends', 'finally', 'for',
  'function', 'if', 'import', 'in', 'instanceof', 'let', 'new', 'of',
  'return', 'static', 'super', 'switch', 'this', 'throw', 'try', 'typeof',
  'var', 'void', 'while', 'with', 'yield', 'async', 'await', 'null', 'true',
  'false', 'undefined',
};

/// Longest first, so `===` is never read as `==` followed by `=`.
const List<String> _operators = <String>[
  '>>>=', '...', '===', '!==', '**=', '<<=', '>>=', '&&=', '||=', '??=', '>>>', //
  '=>', '==', '!=', '<=', '>=', '&&', '||', '??', '?.', '++', '--',
  '+=', '-=', '*=', '/=', '%=', '**', '<<', '>>', '&=', '|=', '^=',
  '+', '-', '*', '/', '%', '=', '<', '>', '!', '?', ':', ';', ',', '.',
  '(', ')', '[', ']', '{', '}', '&', '|', '^', '~',
];

class JavascriptLexer {
  List<JsToken> tokenize(String source) => _Scanner(source).scan();
}

class _Scanner {
  _Scanner(this.source);

  final String source;
  final List<JsToken> tokens = <JsToken>[];
  int i = 0;
  int line = 1;
  bool pendingNewline = false;

  List<JsToken> scan() {
    while (i < source.length) {
      _scanToken();
    }
    _add(JsTokenType.eof, '');
    return tokens;
  }

  void _scanToken() {
    final c = source[i];

    if (c == '\n') {
      line++;
      i++;
      pendingNewline = true;
      return;
    }
    if (c == ' ' || c == '\t' || c == '\r') {
      i++;
      return;
    }
    if (c == '/' && i + 1 < source.length && source[i + 1] == '/') {
      while (i < source.length && source[i] != '\n') {
        i++;
      }
      return;
    }
    if (c == '/' && i + 1 < source.length && source[i + 1] == '*') {
      i += 2;
      while (i < source.length && !source.startsWith('*/', i)) {
        if (source[i] == '\n') {
          line++;
          // A block comment spanning lines counts as a line break for ASI.
          pendingNewline = true;
        }
        i++;
      }
      if (i >= source.length) {
        throw FrontendFailure(kind: FailureKind.syntax, code: 'unterminatedComment', line: line);
      }
      i += 2;
      return;
    }
    if (c == '"' || c == "'") {
      _string(c);
      return;
    }
    if (c == '`') {
      _template();
      return;
    }
    if (_isDigit(c) || (c == '.' && i + 1 < source.length && _isDigit(source[i + 1]))) {
      _number();
      return;
    }
    if (_isIdentifierStart(c)) {
      _identifier();
      return;
    }
    for (final op in _operators) {
      if (source.startsWith(op, i)) {
        // `?.` must not swallow the `?` of `a ? .5 : 1`, which is a ternary
        // whose consequent is a number.
        if (op == '?.' && i + 2 < source.length && _isDigit(source[i + 2])) continue;
        _add(JsTokenType.op, op);
        i += op.length;
        return;
      }
    }
    throw FrontendFailure(
        kind: FailureKind.syntax,
        code: 'unexpectedCharacter',
        data: <String, Object?>{'character': c},
        line: line);
  }

  void _identifier() {
    final start = i;
    while (i < source.length && _isIdentifierPart(source[i])) {
      i++;
    }
    final text = source.substring(start, i);
    _add(jsKeywords.contains(text) ? JsTokenType.keyword : JsTokenType.name, text);
  }

  void _number() {
    final start = i;

    if (source[i] == '0' && i + 1 < source.length && 'xXbBoO'.contains(source[i + 1])) {
      final radix = switch (source[i + 1].toLowerCase()) { 'x' => 16, 'b' => 2, _ => 8 };
      i += 2;
      final digitsStart = i;
      while (i < source.length && (_isAlphaNumeric(source[i]) || source[i] == '_')) {
        i++;
      }
      final parsed = int.tryParse(source.substring(digitsStart, i).replaceAll('_', ''), radix: radix);
      if (parsed == null) {
        throw FrontendFailure(
            kind: FailureKind.syntax,
            code: 'invalidNumber',
            data: <String, Object?>{'text': source.substring(start, i)},
            line: line);
      }
      _add(JsTokenType.numberLiteral, source.substring(start, i), literal: parsed);
      return;
    }

    var isFloat = false;
    while (i < source.length && (_isDigit(source[i]) || source[i] == '_')) {
      i++;
    }
    if (i < source.length && source[i] == '.') {
      isFloat = true;
      i++;
      while (i < source.length && (_isDigit(source[i]) || source[i] == '_')) {
        i++;
      }
    }
    if (i < source.length && (source[i] == 'e' || source[i] == 'E')) {
      final save = i;
      i++;
      if (i < source.length && (source[i] == '+' || source[i] == '-')) i++;
      if (i < source.length && _isDigit(source[i])) {
        isFloat = true;
        while (i < source.length && _isDigit(source[i])) {
          i++;
        }
      } else {
        i = save;
      }
    }

    final text = source.substring(start, i).replaceAll('_', '');
    _add(JsTokenType.numberLiteral, text, literal: isFloat ? double.parse(text) : int.parse(text));
  }

  void _string(String quote) {
    final startLine = line;
    i++;
    final buffer = StringBuffer();
    while (true) {
      if (i >= source.length || source[i] == '\n') {
        throw FrontendFailure(kind: FailureKind.syntax, code: 'unterminatedString', line: startLine);
      }
      if (source[i] == quote) {
        i++;
        break;
      }
      if (source[i] == r'\') {
        i++;
        if (i >= source.length) {
          throw FrontendFailure(kind: FailureKind.syntax, code: 'unterminatedString', line: startLine);
        }
        buffer.write(_unescape(source[i]));
        i++;
        continue;
      }
      buffer.write(source[i]);
      i++;
    }
    _add(JsTokenType.stringLiteral, '', literal: buffer.toString(), atLine: startLine);
  }

  void _template() {
    final startLine = line;
    i++; // past `
    final parts = <Object>[];
    final buffer = StringBuffer();

    while (true) {
      if (i >= source.length) {
        throw FrontendFailure(kind: FailureKind.syntax, code: 'unterminatedString', line: startLine);
      }
      if (source[i] == '`') {
        i++;
        break;
      }
      if (source[i] == r'\') {
        i++;
        if (i >= source.length) {
          throw FrontendFailure(kind: FailureKind.syntax, code: 'unterminatedString', line: startLine);
        }
        buffer.write(_unescape(source[i]));
        i++;
        continue;
      }
      if (source.startsWith(r'${', i)) {
        if (buffer.isNotEmpty) {
          parts.add(buffer.toString());
          buffer.clear();
        }
        parts.add(_templateHole());
        continue;
      }
      if (source[i] == '\n') {
        line++;
        buffer.write('\n');
        i++;
        continue;
      }
      buffer.write(source[i]);
      i++;
    }

    if (buffer.isNotEmpty || parts.isEmpty) parts.add(buffer.toString());
    _add(JsTokenType.templateLiteral, '', literal: parts, atLine: startLine);
  }

  JsInterpolation _templateHole() {
    i += 2; // past ${
    final start = i;
    final holeLine = line;
    var depth = 1;
    while (i < source.length && depth > 0) {
      final c = source[i];
      if (c == '{') depth++;
      if (c == '}') {
        depth--;
        if (depth == 0) break;
      }
      if (c == '\n') line++;
      i++;
    }
    if (depth != 0) {
      throw FrontendFailure(kind: FailureKind.syntax, code: 'unterminatedString', line: holeLine);
    }
    final expr = source.substring(start, i);
    i++; // past }
    if (expr.trim().isEmpty) {
      throw FrontendFailure(kind: FailureKind.syntax, code: 'expectedExpression', line: holeLine);
    }
    return JsInterpolation(expr, holeLine);
  }

  String _unescape(String c) => switch (c) {
        'n' => '\n',
        't' => '\t',
        'r' => '\r',
        '0' => ' ',
        'b' => '\b',
        'f' => '\f',
        'v' => '\v',
        '\\' => '\\',
        "'" => "'",
        '"' => '"',
        '`' => '`',
        r'$' => r'$',
        '\n' => '',
        _ => c,
      };

  void _add(JsTokenType type, String lexeme, {Object? literal, int? atLine}) {
    tokens.add(JsToken(
      type: type,
      lexeme: lexeme,
      line: atLine ?? line,
      newlineBefore: pendingNewline,
      literal: literal,
    ));
    pendingNewline = false;
  }

  static bool _isDigit(String c) => c.codeUnitAt(0) >= 0x30 && c.codeUnitAt(0) <= 0x39;

  static bool _isIdentifierStart(String c) {
    final u = c.codeUnitAt(0);
    return (u >= 0x41 && u <= 0x5A) || (u >= 0x61 && u <= 0x7A) || c == '_' || c == r'$' || u > 0x7F;
  }

  static bool _isIdentifierPart(String c) => _isIdentifierStart(c) || _isDigit(c);

  static bool _isAlphaNumeric(String c) {
    final u = c.codeUnitAt(0);
    return _isDigit(c) || (u >= 0x41 && u <= 0x5A) || (u >= 0x61 && u <= 0x7A);
  }
}
