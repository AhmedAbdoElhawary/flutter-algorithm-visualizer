import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/errors/failure.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/frontend/python/python_lexer.dart';
import 'package:flutter_test/flutter_test.dart';

List<PythonToken> _lex(String source) => PythonLexer().tokenize(source);

Object? _literal(String source) => _lex(source).first.literal;

String _str(String source) => (_literal(source)! as List<Object>).single as String;

Matcher _fails(String code) => throwsA(isA<FrontendFailure>().having((f) => f.code, 'code', code));

void main() {
  test('a trailing comment is dropped', () {
    expect(_lex('x = 1  # the answer').map((t) => t.type), [
      PythonTokenType.name,
      PythonTokenType.op,
      PythonTokenType.intLiteral,
      PythonTokenType.newline,
      PythonTokenType.eof,
    ]);
  });

  test('a token prints its type, value and line', () {
    expect(_lex('7').first.toString(), 'PythonTokenType.intLiteral(7) @1');
  });

  group('numbers', () {
    test('hex, binary and octal read in their own base', () {
      expect(_literal('0xFF'), 255);
      expect(_literal('0b1010'), 10);
      expect(_literal('0o17'), 15);
      expect(_literal('0xff_ff'), 65535);
    });

    test('a digit outside the base is an invalid number', () {
      expect(() => _lex('0b12'), _fails('invalidNumber'));
    });

    test('an exponent or a trailing dot makes a float', () {
      expect(_literal('1e3'), 1000.0);
      expect(_literal('2.5E-2'), 0.025);
      expect(_literal('1.'), 1.0);
    });

    test('an e with no digits after it is a name, not an exponent', () {
      final tokens = _lex('1e');
      expect(tokens[0].literal, 1);
      expect(tokens[1].lexeme, 'e');
    });
  });

  group('strings', () {
    test('escapes turn into the characters they name', () {
      expect(_str(r'"\t\r\b\f\v"'), '\t\r\b\f\v');
      expect(_str(r'''"\\ \' \""'''), '\\ \' "');
      expect(_str(r'"\0"'), '\x00');
      expect(_str(r'"\q"'), 'q');
    });

    test('a backslash at the end of a line joins it to the next', () {
      expect(_str('"ab\\\ncd"'), 'abcd');
    });

    test('a line joined inside a string still counts as a line', () {
      expect(_lex('"ab\\\ncd"\nx').map((t) => t.line), [1, 2, 3, 3, 3]);
      expect(_lex('r"ab\\\ncd"\nx').map((t) => t.line), [1, 2, 3, 3, 3]);
    });

    test('a raw string keeps a joined line as written', () {
      expect(_str('r"ab\\\ncd"'), 'ab\\\ncd');
    });

    test('a raw string keeps its backslashes', () {
      expect(_str(r'r"\n\d"'), r'\n\d');
    });

    test('a string with no closing quote is unterminated', () {
      expect(() => _lex('"abc'), _fails('unterminatedString'));
      expect(() => _lex('"abc\\'), _fails('unterminatedString'));
    });

    test('a lone } in an f-string is an unexpected character', () {
      expect(() => _lex('f"a}"'), _fails('unexpectedCharacter'));
    });

    test('an f-string hole with no end or nothing inside is an error', () {
      expect(() => _lex('f"{a'), _fails('unterminatedString'));
      expect(() => _lex('f"{ }"'), _fails('expectedExpression'));
    });

    test('an f-string hole may span lines', () {
      final parts = _literal('f"""{(1 +\n 2)}"""')! as List<Object>;
      expect((parts.single as PythonInterpolation).source, '(1 +\n 2)');
    });
  });

  test('a character Python does not use is reported by name', () {
    expect(
      () => _lex(r'x = $'),
      throwsA(isA<FrontendFailure>().having((f) => f.data['character'], 'character', r'$')),
    );
  });
}
