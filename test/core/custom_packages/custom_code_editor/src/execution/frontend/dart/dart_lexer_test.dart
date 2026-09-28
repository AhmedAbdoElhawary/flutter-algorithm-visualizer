import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/errors/failure.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/frontend/dart/dart_lexer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<DartTokenType> types(String source) => DartLexer().tokenize(source).map((t) => t.type).toList();

  String? failureOf(String source) {
    try {
      DartLexer().tokenize(source);
      return null;
    } on FrontendFailure catch (f) {
      return f.code;
    }
  }

  test('every operator, longest match first', () {
    expect(
      types('?. ?? ??= ~/ ~/= ++ -- += -= *= /= %= == != <= >= && || => ! < >'),
      [
        DartTokenType.questionDot,
        DartTokenType.questionQuestion,
        DartTokenType.questionQuestionEqual,
        DartTokenType.tildeSlash,
        DartTokenType.tildeSlashEqual,
        DartTokenType.plusPlus,
        DartTokenType.minusMinus,
        DartTokenType.plusEqual,
        DartTokenType.minusEqual,
        DartTokenType.starEqual,
        DartTokenType.slashEqual,
        DartTokenType.percentEqual,
        DartTokenType.equalEqual,
        DartTokenType.bangEqual,
        DartTokenType.lessEqual,
        DartTokenType.greaterEqual,
        DartTokenType.ampAmp,
        DartTokenType.pipePipe,
        DartTokenType.arrow,
        DartTokenType.bang,
        DartTokenType.less,
        DartTokenType.greater,
        DartTokenType.eof,
      ],
    );
  });

  test('numbers: ints, doubles and exponents, with their values', () {
    final tokens = DartLexer().tokenize('42 3.5 1e3 2.5E-1');

    expect(tokens.take(4).map((t) => t.literal), [42, 3.5, 1000.0, 0.25]);
    expect(tokens.first.type, DartTokenType.intLiteral);
    expect(tokens[2].type, DartTokenType.doubleLiteral);
  });

  test('a dot after a number is a method call, not a fraction', () {
    expect(types('3.abs()').take(3), [DartTokenType.intLiteral, DartTokenType.dot, DartTokenType.identifier]);
  });

  group('strings', () {
    test('escapes', () {
      expect(DartLexer().tokenize(r"'a\'b\n'").first.literal, ["a'b\n"]);
    });

    test('interpolation, short and braced, becomes separate parts', () {
      final parts = DartLexer().tokenize(r"'x=$x, sum=${a + b}!'").first.literal! as List<Object>;

      expect(parts[0], 'x=');
      expect((parts[1] as InterpolationSlice).source, 'x');
      expect(parts[2], ', sum=');
      expect((parts[3] as InterpolationSlice).source, 'a + b');
      expect(parts[4], '!');
    });

    test('a triple-quoted string may span lines, and the lines keep counting', () {
      final tokens = DartLexer().tokenize("'''a\nb'''\nx");

      expect(tokens.first.literal, ['a\nb']);
      expect(tokens[1].line, 3);
    });

    test('an unclosed string is a syntax error, on one line or across a newline', () {
      expect(failureOf("'open"), 'unterminatedString');
      expect(failureOf("'open\n'"), 'unterminatedString');
      expect(failureOf(r"'${a'"), 'unterminatedString');
    });
  });

  test('comments are skipped, block comments nest, and lines are still counted', () {
    final tokens = DartLexer().tokenize('a // note\n/* x /* y */ z\n*/ b');

    final kinds = tokens.map((t) => t.type);
    expect(kinds, [DartTokenType.identifier, DartTokenType.identifier, DartTokenType.eof]);
    expect(tokens[1].line, 3);
  });

  test('a character Dart does not have here is a clear syntax error', () {
    expect(failureOf('a @ b'), 'unexpectedCharacter');
    expect(failureOf('a & b'), 'unexpectedCharacter');
    expect(failureOf('a | b'), 'unexpectedCharacter');
    expect(failureOf('~a'), 'unexpectedCharacter');
  });

  test('a token prints its type, value and line', () {
    expect(DartLexer().tokenize('7').first.toString(), 'DartTokenType.intLiteral(7) @1');
  });
}
