import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/errors/failure.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/frontend/javascript/javascript_lexer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<String> lexemes(String source) => JavascriptLexer().tokenize(source).map((t) => t.lexeme).toList();

  String? failureOf(String source) {
    try {
      JavascriptLexer().tokenize(source);
      return null;
    } on FrontendFailure catch (f) {
      return f.code;
    }
  }

  test('operators are read longest first', () {
    expect(lexemes('a === b !== c ?? d ... e >>>= f'), [
      'a', '===', 'b', '!==', 'c', '??', 'd', '...', 'e', '>>>=', 'f', '', //
    ]);
  });

  test('a ?. followed by a digit is a ternary, not optional chaining', () {
    expect(lexemes('a ?.5 : 1'), ['a', '?', '.5', ':', '1', '']);
  });

  test('keywords and names', () {
    final tokens = JavascriptLexer().tokenize('let count = null');

    expect(tokens.map((t) => t.type).take(4), [
      JsTokenType.keyword,
      JsTokenType.name,
      JsTokenType.op,
      JsTokenType.keyword,
    ]);
  });

  group('numbers', () {
    test('decimal, fraction, exponent, separators and other bases', () {
      final tokens = JavascriptLexer().tokenize('7 .5 1e2 1_000 0xff 0b101 0o17');
      final values = tokens.map((t) => t.literal).toList();

      expect(values.take(7), [7, 0.5, 100, 1000, 255, 5, 15]);
    });

    test('a broken hex number is a syntax error', () {
      expect(failureOf('0xZZ'), 'invalidNumber');
    });
  });

  group('strings and templates', () {
    test('escapes in either quote', () {
      const source = r'''  'a\'b'  "c\nd"  ''';
      final values = JavascriptLexer().tokenize(source).take(2).map((t) => t.literal);

      expect(values, ["a'b", 'c\nd']);
    });

    test('a template keeps its text and holes apart', () {
      final parts = JavascriptLexer().tokenize(r'`sum: ${a + b}!`').first.literal! as List<Object>;

      expect(parts.first, 'sum: ');
      expect((parts[1] as JsInterpolation).source, 'a + b');
      expect(parts.last, '!');
    });

    test('unclosed strings, templates and holes are syntax errors', () {
      expect(failureOf("'open"), 'unterminatedString');
      expect(failureOf('`open'), 'unterminatedString');
      expect(failureOf(r'`${a`'), 'unterminatedString');
      expect(failureOf(r'`${}`'), 'expectedExpression');
    });
  });

  group('comments and line breaks', () {
    test('comments are skipped, an unclosed block comment is an error', () {
      expect(lexemes('a // x\nb /* y */ c'), ['a', 'b', 'c', '']);
      expect(failureOf('a /* never closed'), 'unterminatedComment');
    });

    test('each token knows whether a line break came before it', () {
      final tokens = JavascriptLexer().tokenize('a\nb /*\n*/ c d');

      expect(tokens.map((t) => t.newlineBefore).take(4), [false, true, true, false]);
      expect(tokens[1].line, 2);
    });
  });

  test('a character JavaScript does not have is a clear syntax error', () {
    expect(failureOf('a # b'), 'unexpectedCharacter');
  });
}
