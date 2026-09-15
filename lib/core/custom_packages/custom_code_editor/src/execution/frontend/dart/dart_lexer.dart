/// A lexer for the supported Dart subset. Character-level scanning only —
/// string interpolation boundaries are found here (so escapes and nested
/// quotes are handled once, correctly) but each `${...}`/`$name` slice's
/// *contents* are re-lexed and parsed by `dart_parser.dart` recursively.
library;

import '../../errors/failure.dart';

enum DartTokenType {
  leftParen, rightParen, leftBrace, rightBrace, leftBracket, rightBracket,
  comma, dot, question, questionDot, questionQuestion, questionQuestionEqual,
  colon, semicolon,
  plus, minus, star, slash, tildeSlash, percent,
  plusPlus, minusMinus,
  plusEqual, minusEqual, starEqual, slashEqual, tildeSlashEqual, percentEqual,
  equal, equalEqual, bangEqual, bang,
  less, lessEqual, greater, greaterEqual,
  ampAmp, pipePipe,
  arrow,
  identifier, intLiteral, doubleLiteral, stringLiteral, boolLiteral, nullLiteral,
  eof,
}

/// One `${...}` or `$identifier` interpolation inside a string literal —
/// the raw, not-yet-parsed Dart source of the embedded expression.
class InterpolationSlice {
  const InterpolationSlice(this.source, this.line);
  final String source;
  final int line;
}

class DartToken {
  const DartToken({required this.type, required this.lexeme, required this.line, this.literal});
  final DartTokenType type;
  final String lexeme;
  final int line;

  /// `int`/`double` for numeric literals; `List<Object>` (alternating
  /// `String` and [InterpolationSlice]) for string literals.
  final Object? literal;

  @override
  String toString() => '$type(${literal ?? lexeme}) @$line';
}

class DartLexer {
  List<DartToken> tokenize(String source) {
    final tokens = <DartToken>[];
    var i = 0;
    var line = 1;

    void addSimple(DartTokenType type, String lexeme, int len) {
      tokens.add(DartToken(type: type, lexeme: lexeme, line: line));
      i += len;
    }

    while (i < source.length) {
      final c = source[i];

      if (c == '\n') {
        line++;
        i++;
        continue;
      }
      if (c == ' ' || c == '\t' || c == '\r') {
        i++;
        continue;
      }
      if (c == '/' && i + 1 < source.length && source[i + 1] == '/') {
        while (i < source.length && source[i] != '\n') {
          i++;
        }
        continue;
      }
      if (c == '/' && i + 1 < source.length && source[i + 1] == '*') {
        var depth = 1;
        i += 2;
        while (i < source.length && depth > 0) {
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
          if (source[i] == '\n') line++;
          i++;
        }
        continue;
      }

      if (c == '"' || c == "'") {
        final start = line;
        final (literal, newIndex, newLine) = _scanString(source, i, line);
        tokens.add(DartToken(type: DartTokenType.stringLiteral, lexeme: source.substring(i, newIndex), line: start, literal: literal));
        i = newIndex;
        line = newLine;
        continue;
      }

      if (_isDigit(c)) {
        final (token, newIndex) = _scanNumber(source, i, line);
        tokens.add(token);
        i = newIndex;
        continue;
      }

      if (_isIdentStart(c)) {
        final start = i;
        while (i < source.length && _isIdentPart(source[i])) {
          i++;
        }
        final lexeme = source.substring(start, i);
        switch (lexeme) {
          case 'true':
            tokens.add(DartToken(type: DartTokenType.boolLiteral, lexeme: lexeme, line: line, literal: true));
          case 'false':
            tokens.add(DartToken(type: DartTokenType.boolLiteral, lexeme: lexeme, line: line, literal: false));
          case 'null':
            tokens.add(DartToken(type: DartTokenType.nullLiteral, lexeme: lexeme, line: line));
          default:
            tokens.add(DartToken(type: DartTokenType.identifier, lexeme: lexeme, line: line));
        }
        continue;
      }

      switch (c) {
        case '(':
          addSimple(DartTokenType.leftParen, c, 1);
        case ')':
          addSimple(DartTokenType.rightParen, c, 1);
        case '{':
          addSimple(DartTokenType.leftBrace, c, 1);
        case '}':
          addSimple(DartTokenType.rightBrace, c, 1);
        case '[':
          addSimple(DartTokenType.leftBracket, c, 1);
        case ']':
          addSimple(DartTokenType.rightBracket, c, 1);
        case ',':
          addSimple(DartTokenType.comma, c, 1);
        case '.':
          addSimple(DartTokenType.dot, c, 1);
        case ':':
          addSimple(DartTokenType.colon, c, 1);
        case ';':
          addSimple(DartTokenType.semicolon, c, 1);
        case '?':
          if (_peek(source, i, '??=')) {
            addSimple(DartTokenType.questionQuestionEqual, '??=', 3);
          } else if (_peek(source, i, '??')) {
            addSimple(DartTokenType.questionQuestion, '??', 2);
          } else if (_peek(source, i, '?.')) {
            addSimple(DartTokenType.questionDot, '?.', 2);
          } else {
            addSimple(DartTokenType.question, c, 1);
          }
        case '+':
          if (_peek(source, i, '++')) {
            addSimple(DartTokenType.plusPlus, '++', 2);
          } else if (_peek(source, i, '+=')) {
            addSimple(DartTokenType.plusEqual, '+=', 2);
          } else {
            addSimple(DartTokenType.plus, c, 1);
          }
        case '-':
          if (_peek(source, i, '--')) {
            addSimple(DartTokenType.minusMinus, '--', 2);
          } else if (_peek(source, i, '-=')) {
            addSimple(DartTokenType.minusEqual, '-=', 2);
          } else {
            addSimple(DartTokenType.minus, c, 1);
          }
        case '*':
          if (_peek(source, i, '*=')) {
            addSimple(DartTokenType.starEqual, '*=', 2);
          } else {
            addSimple(DartTokenType.star, c, 1);
          }
        case '~':
          if (_peek(source, i, '~/=')) {
            addSimple(DartTokenType.tildeSlashEqual, '~/=', 3);
          } else if (_peek(source, i, '~/')) {
            addSimple(DartTokenType.tildeSlash, '~/', 2);
          } else {
            throw FrontendFailure(kind: FailureKind.syntax, code: 'unexpectedCharacter', data: <String, Object?>{'char': c}, line: line);
          }
        case '/':
          if (_peek(source, i, '/=')) {
            addSimple(DartTokenType.slashEqual, '/=', 2);
          } else {
            addSimple(DartTokenType.slash, c, 1);
          }
        case '%':
          if (_peek(source, i, '%=')) {
            addSimple(DartTokenType.percentEqual, '%=', 2);
          } else {
            addSimple(DartTokenType.percent, c, 1);
          }
        case '=':
          if (_peek(source, i, '==')) {
            addSimple(DartTokenType.equalEqual, '==', 2);
          } else if (_peek(source, i, '=>')) {
            addSimple(DartTokenType.arrow, '=>', 2);
          } else {
            addSimple(DartTokenType.equal, c, 1);
          }
        case '!':
          if (_peek(source, i, '!=')) {
            addSimple(DartTokenType.bangEqual, '!=', 2);
          } else {
            addSimple(DartTokenType.bang, c, 1);
          }
        case '<':
          if (_peek(source, i, '<=')) {
            addSimple(DartTokenType.lessEqual, '<=', 2);
          } else {
            addSimple(DartTokenType.less, c, 1);
          }
        case '>':
          if (_peek(source, i, '>=')) {
            addSimple(DartTokenType.greaterEqual, '>=', 2);
          } else {
            addSimple(DartTokenType.greater, c, 1);
          }
        case '&':
          if (_peek(source, i, '&&')) {
            addSimple(DartTokenType.ampAmp, '&&', 2);
          } else {
            throw FrontendFailure(kind: FailureKind.syntax, code: 'unexpectedCharacter', data: <String, Object?>{'char': c}, line: line);
          }
        case '|':
          if (_peek(source, i, '||')) {
            addSimple(DartTokenType.pipePipe, '||', 2);
          } else {
            throw FrontendFailure(kind: FailureKind.syntax, code: 'unexpectedCharacter', data: <String, Object?>{'char': c}, line: line);
          }
        default:
          throw FrontendFailure(kind: FailureKind.syntax, code: 'unexpectedCharacter', data: <String, Object?>{'char': c}, line: line);
      }
    }

    tokens.add(DartToken(type: DartTokenType.eof, lexeme: '', line: line));
    return tokens;
  }

  bool _peek(String source, int i, String expect) => i + expect.length <= source.length && source.substring(i, i + expect.length) == expect;

  bool _isDigit(String c) => c.codeUnitAt(0) >= 0x30 && c.codeUnitAt(0) <= 0x39;
  bool _isIdentStart(String c) => RegExp(r'[A-Za-z_$]').hasMatch(c);
  bool _isIdentPart(String c) => RegExp(r'[A-Za-z0-9_$]').hasMatch(c);

  (DartToken, int) _scanNumber(String source, int start, int line) {
    var i = start;
    while (i < source.length && _isDigit(source[i])) {
      i++;
    }
    var isDouble = false;
    if (i < source.length && source[i] == '.' && i + 1 < source.length && _isDigit(source[i + 1])) {
      isDouble = true;
      i++;
      while (i < source.length && _isDigit(source[i])) {
        i++;
      }
    }
    if (i < source.length && (source[i] == 'e' || source[i] == 'E')) {
      isDouble = true;
      i++;
      if (i < source.length && (source[i] == '+' || source[i] == '-')) i++;
      while (i < source.length && _isDigit(source[i])) {
        i++;
      }
    }
    final text = source.substring(start, i);
    if (isDouble) {
      return (DartToken(type: DartTokenType.doubleLiteral, lexeme: text, line: line, literal: double.parse(text)), i);
    }
    return (DartToken(type: DartTokenType.intLiteral, lexeme: text, line: line, literal: int.parse(text)), i);
  }

  /// Scans a single- or triple-quoted string starting at [start] (pointing
  /// at the opening quote), returning its interpolation-aware literal parts,
  /// the index just past the closing quote, and the line after it.
  (List<Object>, int, int) _scanString(String source, int start, int startLine) {
    final quoteChar = source[start];
    final isTriple = _peek3(source, start, quoteChar);
    final quoteLen = isTriple ? 3 : 1;
    var i = start + quoteLen;
    var line = startLine;
    final parts = <Object>[];
    final buffer = StringBuffer();

    void flush() {
      if (buffer.isNotEmpty) {
        parts.add(buffer.toString());
        buffer.clear();
      }
    }

    while (true) {
      if (i >= source.length) {
        throw FrontendFailure(kind: FailureKind.syntax, code: 'unterminatedString', line: line);
      }
      if (!isTriple && source[i] == '\n') {
        throw FrontendFailure(kind: FailureKind.syntax, code: 'unterminatedString', line: line);
      }
      if (source[i] == quoteChar) {
        if (!isTriple) {
          i++;
          break;
        }
        if (_peek3(source, i, quoteChar)) {
          i += 3;
          break;
        }
      }
      if (source[i] == '\n') line++;

      if (source[i] == '\\' && i + 1 < source.length) {
        buffer.write(_unescape(source[i + 1]));
        i += 2;
        continue;
      }

      if (source[i] == r'$' && i + 1 < source.length) {
        if (source[i + 1] == '{') {
          flush();
          final exprStart = i + 2;
          var depth = 1;
          var j = exprStart;
          while (j < source.length && depth > 0) {
            if (source[j] == '{') depth++;
            if (source[j] == '}') depth--;
            if (depth == 0) break;
            if (source[j] == '\n') line++;
            j++;
          }
          if (depth != 0) throw FrontendFailure(kind: FailureKind.syntax, code: 'unterminatedString', line: line);
          parts.add(InterpolationSlice(source.substring(exprStart, j), line));
          i = j + 1;
          continue;
        }
        if (_isIdentStart(source[i + 1])) {
          flush();
          var j = i + 1;
          while (j < source.length && _isIdentPart(source[j])) {
            j++;
          }
          parts.add(InterpolationSlice(source.substring(i + 1, j), line));
          i = j;
          continue;
        }
      }

      buffer.write(source[i]);
      i++;
    }

    flush();
    return (parts, i, line);
  }

  bool _peek3(String source, int i, String quoteChar) => i + 3 <= source.length && source[i] == quoteChar && source[i + 1] == quoteChar && source[i + 2] == quoteChar;

  String _unescape(String c) {
    switch (c) {
      case 'n':
        return '\n';
      case 't':
        return '\t';
      case 'r':
        return '\r';
      case r'$':
        return r'$';
      case '\\':
        return '\\';
      case "'":
        return "'";
      case '"':
        return '"';
      default:
        return c;
    }
  }
}
