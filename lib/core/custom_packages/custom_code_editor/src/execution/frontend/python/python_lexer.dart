/// An indentation-aware lexer for the supported Python subset.
///
/// The only genuinely unusual job here is turning leading whitespace into
/// explicit [PythonTokenType.indent] / [PythonTokenType.dedent] tokens, so
/// that the parser can treat a Python block exactly like a braced block in
/// any other language. Everything downstream of this file is
/// indentation-blind.
///
/// Three rules make that work, and all three are places learners actually
/// get caught out (Risk R3):
///
/// * **Blank and comment-only lines carry no indentation.** They are skipped
///   whole, so a blank line inside a block does not close the block.
/// * **Inside brackets, newlines do not end a statement** (implicit line
///   joining), so a list literal may span as many lines as it likes at any
///   indentation. A trailing `\` joins lines explicitly.
/// * **A dedent must land exactly on a level that is already open.** Landing
///   between two levels is the classic "unindent does not match" mistake, and
///   it is reported as an indentation error naming that line — never as a
///   vague syntax error.
library;

import '../../errors/failure.dart';

enum PythonTokenType {
  name,
  keyword,
  intLiteral,
  floatLiteral,
  stringLiteral,
  op,

  /// End of a logical line.
  newline,
  indent,
  dedent,
  eof,
}

/// One `{...}` hole inside an f-string: the raw, not-yet-parsed Python source
/// of the embedded expression. `python_parser.dart` re-lexes and parses it.
class PythonInterpolation {
  const PythonInterpolation(this.source, this.line);
  final String source;
  final int line;
}

class PythonToken {
  const PythonToken({required this.type, required this.lexeme, required this.line, this.literal});

  final PythonTokenType type;
  final String lexeme;
  final int line;

  /// `int`/`double` for numeric literals; `List<Object>` (alternating
  /// `String` and [PythonInterpolation]) for string literals.
  final Object? literal;

  @override
  String toString() => '$type(${literal ?? lexeme}) @$line';
}

const Set<String> pythonKeywords = <String>{
  'False', 'None', 'True', 'and', 'as', 'assert', 'async', 'await', 'break', //
  'class', 'continue', 'def', 'del', 'elif', 'else', 'except', 'finally',
  'for', 'from', 'global', 'if', 'import', 'in', 'is', 'lambda', 'nonlocal',
  'not', 'or', 'pass', 'raise', 'return', 'try', 'while', 'with', 'yield',
};

/// Longest first, so that `**=` is never mis-read as `**` followed by `=`.
const List<String> _operators = <String>[
  '**=', '//=', '<<=', '>>=', '...', //
  '**', '//', '==', '!=', '<=', '>=', '+=', '-=', '*=', '/=', '%=', '->', ':=',
  '<<', '>>', '&=', '|=', '^=',
  '+', '-', '*', '/', '%', '=', '<', '>', '(', ')', '[', ']', '{', '}', ',',
  ':', '.', ';', '~', '&', '|', '^', '@',
];

/// A tab advances to the next multiple of this, which is what CPython uses
/// when it compares one line's indentation with another's.
const int _tabWidth = 8;

class PythonLexer {
  List<PythonToken> tokenize(String source) => _Scanner(source).scan();
}

class _Scanner {
  _Scanner(this.source);

  final String source;
  final List<PythonToken> tokens = <PythonToken>[];

  /// Open indentation levels, in columns. Level 0 is always open.
  final List<int> indents = <int>[0];

  int i = 0;
  int line = 1;

  /// Depth of unclosed `(`, `[` and `{`. While positive, newlines are
  /// insignificant and no indentation is measured.
  int bracketDepth = 0;

  /// Whether the current logical line has produced any token yet — used to
  /// avoid emitting a NEWLINE for a line that was entirely blank.
  bool lineHasContent = false;

  List<PythonToken> scan() {
    _startOfLine();
    while (i < source.length) {
      _scanToken();
    }
    if (lineHasContent) _add(PythonTokenType.newline, '\n');
    while (indents.length > 1) {
      indents.removeLast();
      _add(PythonTokenType.dedent, '');
    }
    _add(PythonTokenType.eof, '');
    return tokens;
  }

  // -------------------------------------------------------------------
  // Line and indentation handling
  // -------------------------------------------------------------------

  /// Called at the very start of the file and after every significant
  /// newline. Skips blank and comment-only lines entirely, then compares this
  /// line's indentation against the open levels.
  void _startOfLine() {
    while (i < source.length) {
      final startedAt = i;
      var column = 0;
      var sawSpace = false;

      while (i < source.length) {
        final c = source[i];
        if (c == ' ') {
          column++;
          sawSpace = true;
          i++;
        } else if (c == '\t') {
          if (sawSpace) {
            // A tab after a space means the line's real width depends on the
            // reader's tab settings — the mistake that silently breaks a
            // block. CPython rejects it too.
            throw FrontendFailure(
                kind: FailureKind.syntax,
                code: 'indentationError',
                data: const <String, Object?>{'reason': 'mixedTabsAndSpaces'},
                line: line);
          }
          column += _tabWidth - (column % _tabWidth);
          i++;
        } else {
          break;
        }
      }

      // A line that is blank, or holds nothing but a comment, has no
      // indentation of its own and must not close an open block.
      if (i >= source.length) return;
      if (source[i] == '\n' || source[i] == '\r') {
        _consumeNewline();
        continue;
      }
      if (source[i] == '#') {
        while (i < source.length && source[i] != '\n') {
          i++;
        }
        continue;
      }

      _applyIndentation(column, startedAt);
      return;
    }
  }

  void _applyIndentation(int column, int startedAt) {
    if (column > indents.last) {
      indents.add(column);
      _add(PythonTokenType.indent, source.substring(startedAt, i));
      return;
    }
    while (column < indents.last) {
      indents.removeLast();
      _add(PythonTokenType.dedent, '');
    }
    if (column != indents.last) {
      // Landed between two open levels: the "unindent does not match any
      // outer indentation level" case.
      throw FrontendFailure(
          kind: FailureKind.syntax,
          code: 'indentationError',
          data: <String, Object?>{'reason': 'unexpectedIndent', 'column': column},
          line: line);
    }
  }

  void _consumeNewline() {
    if (source[i] == '\r' && i + 1 < source.length && source[i + 1] == '\n') i++;
    i++;
    line++;
  }

  // -------------------------------------------------------------------
  // Tokens
  // -------------------------------------------------------------------

  void _scanToken() {
    final c = source[i];

    if (c == '\r' || c == '\n') {
      _consumeNewline();
      if (bracketDepth > 0) return; // implicit line joining
      if (lineHasContent) {
        _add(PythonTokenType.newline, '\n', atLine: line - 1);
        lineHasContent = false;
      }
      _startOfLine();
      return;
    }
    if (c == ' ' || c == '\t') {
      i++;
      return;
    }
    if (c == '\\' && i + 1 < source.length && (source[i + 1] == '\n' || source[i + 1] == '\r')) {
      i++;
      _consumeNewline();
      return;
    }
    if (c == '#') {
      while (i < source.length && source[i] != '\n') {
        i++;
      }
      return;
    }
    if (_isStringStart()) {
      _string();
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
        if (op == '(' || op == '[' || op == '{') bracketDepth++;
        if (op == ')' || op == ']' || op == '}') {
          if (bracketDepth > 0) bracketDepth--;
        }
        _add(PythonTokenType.op, op);
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
    _add(pythonKeywords.contains(text) ? PythonTokenType.keyword : PythonTokenType.name, text);
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
      final digits = source.substring(digitsStart, i).replaceAll('_', '');
      final parsed = int.tryParse(digits, radix: radix);
      if (parsed == null) {
        throw FrontendFailure(
            kind: FailureKind.syntax,
            code: 'invalidNumber',
            data: <String, Object?>{'text': source.substring(start, i)},
            line: line);
      }
      _add(PythonTokenType.intLiteral, source.substring(start, i), literal: parsed);
      return;
    }

    var isFloat = false;
    while (i < source.length && (_isDigit(source[i]) || source[i] == '_')) {
      i++;
    }
    if (i < source.length && source[i] == '.' && i + 1 < source.length && _isDigit(source[i + 1])) {
      isFloat = true;
      i++;
      while (i < source.length && (_isDigit(source[i]) || source[i] == '_')) {
        i++;
      }
    } else if (i < source.length && source[i] == '.' && !source.startsWith('..', i)) {
      // A trailing dot, as in `1.` — still a float.
      isFloat = true;
      i++;
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
    if (isFloat) {
      _add(PythonTokenType.floatLiteral, text, literal: double.parse(text));
    } else {
      _add(PythonTokenType.intLiteral, text, literal: int.parse(text));
    }
  }

  // -------------------------------------------------------------------
  // Strings
  // -------------------------------------------------------------------

  bool _isStringStart() {
    final c = source[i];
    if (c == '"' || c == "'") return true;
    if (!'fFrRbB'.contains(c)) return false;
    // At most a two-letter prefix (`rf"`, `fr"`), then a quote.
    var j = i;
    var letters = 0;
    while (j < source.length && letters < 2 && 'fFrRbB'.contains(source[j])) {
      j++;
      letters++;
    }
    return j < source.length && (source[j] == '"' || source[j] == "'");
  }

  void _string() {
    final startLine = line;
    var isFormat = false;
    var isRaw = false;
    while ('fFrRbB'.contains(source[i])) {
      if (source[i] == 'f' || source[i] == 'F') isFormat = true;
      if (source[i] == 'r' || source[i] == 'R') isRaw = true;
      i++;
    }

    final quote = source[i];
    final isTriple = source.startsWith(quote * 3, i);
    final terminator = isTriple ? quote * 3 : quote;
    i += terminator.length;

    final parts = <Object>[];
    final buffer = StringBuffer();

    while (true) {
      if (i >= source.length) {
        throw FrontendFailure(
            kind: FailureKind.syntax, code: 'unterminatedString', line: startLine);
      }
      if (source.startsWith(terminator, i)) {
        i += terminator.length;
        break;
      }
      final c = source[i];
      if (c == '\n') {
        if (!isTriple) {
          throw FrontendFailure(
              kind: FailureKind.syntax, code: 'unterminatedString', line: startLine);
        }
        buffer.write('\n');
        _consumeNewline();
        continue;
      }
      if (c == '\\' && !isRaw) {
        i++;
        if (i >= source.length) {
          throw FrontendFailure(
              kind: FailureKind.syntax, code: 'unterminatedString', line: startLine);
        }
        buffer.write(_unescape(source[i]));
        i++;
        continue;
      }
      if (c == '\\' && isRaw) {
        buffer.write(c);
        i++;
        if (i < source.length) {
          buffer.write(source[i]);
          i++;
        }
        continue;
      }
      if (isFormat && c == '{') {
        if (source.startsWith('{{', i)) {
          buffer.write('{');
          i += 2;
          continue;
        }
        if (buffer.isNotEmpty) {
          parts.add(buffer.toString());
          buffer.clear();
        }
        parts.add(_formatHole());
        continue;
      }
      if (isFormat && c == '}') {
        if (source.startsWith('}}', i)) {
          buffer.write('}');
          i += 2;
          continue;
        }
        throw FrontendFailure(
            kind: FailureKind.syntax,
            code: 'unexpectedCharacter',
            data: const <String, Object?>{'character': '}'},
            line: line);
      }
      buffer.write(c);
      i++;
    }

    if (buffer.isNotEmpty || parts.isEmpty) parts.add(buffer.toString());
    _add(PythonTokenType.stringLiteral, '', literal: parts, atLine: startLine);
  }

  /// Reads one `{expr}` hole of an f-string, leaving [i] just past its `}`.
  PythonInterpolation _formatHole() {
    i++; // past '{'
    final start = i;
    final holeLine = line;
    var depth = 1;
    while (i < source.length && depth > 0) {
      final c = source[i];
      if (c == '{' || c == '[' || c == '(') depth++;
      if (c == '}' || c == ']' || c == ')') depth--;
      if (depth == 0) break;
      if (c == '\n') {
        _consumeNewline();
        continue;
      }
      // A format spec or conversion would change how the value is rendered,
      // and the engine compares rendered output — so silently dropping one
      // would silently change the answer. Say so instead.
      if (depth == 1 && (c == ':' || c == '!') && !source.startsWith('!=', i)) {
        throw FrontendFailure(
            kind: FailureKind.unsupported,
            code: 'unsupportedConstruct',
            data: const <String, Object?>{'construct': 'fStringFormatSpec'},
            line: holeLine);
      }
      i++;
    }
    if (depth != 0) {
      throw FrontendFailure(kind: FailureKind.syntax, code: 'unterminatedString', line: holeLine);
    }
    final expr = source.substring(start, i);
    i++; // past '}'
    if (expr.trim().isEmpty) {
      throw FrontendFailure(
          kind: FailureKind.syntax, code: 'expectedExpression', line: holeLine);
    }
    return PythonInterpolation(expr, holeLine);
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
        '\n' => '',
        _ => c,
      };

  // -------------------------------------------------------------------

  void _add(PythonTokenType type, String lexeme, {Object? literal, int? atLine}) {
    tokens.add(PythonToken(type: type, lexeme: lexeme, line: atLine ?? line, literal: literal));
    if (type != PythonTokenType.newline && type != PythonTokenType.dedent) lineHasContent = true;
  }

  static bool _isDigit(String c) => c.codeUnitAt(0) >= 0x30 && c.codeUnitAt(0) <= 0x39;

  static bool _isIdentifierStart(String c) {
    final u = c.codeUnitAt(0);
    return (u >= 0x41 && u <= 0x5A) || (u >= 0x61 && u <= 0x7A) || c == '_' || u > 0x7F;
  }

  static bool _isIdentifierPart(String c) => _isIdentifierStart(c) || _isDigit(c);

  static bool _isAlphaNumeric(String c) {
    final u = c.codeUnitAt(0);
    return _isDigit(c) || (u >= 0x41 && u <= 0x5A) || (u >= 0x61 && u <= 0x7A);
  }
}
