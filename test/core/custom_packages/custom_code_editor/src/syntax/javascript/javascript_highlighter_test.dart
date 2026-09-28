import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../highlight_test_support.dart';

void main() {
  const js = JavascriptTokenizer();

  test('keywords, builtins, names, operators and punctuation', () {
    expect(kinds(js, 'const n = Math.max(a, b) ?? 0;'), [
      (TokenType.keyword, 'const'),
      (TokenType.identifier, 'n'),
      (TokenType.operator, '='),
      (TokenType.builtin, 'Math'),
      (TokenType.punctuation, '.'),
      (TokenType.identifier, 'max'),
      (TokenType.punctuation, '('),
      (TokenType.identifier, 'a'),
      (TokenType.punctuation, ','),
      (TokenType.identifier, 'b'),
      (TokenType.punctuation, ')'),
      (TokenType.operator, '??'),
      (TokenType.number, '0'),
      (TokenType.punctuation, ';'),
    ]);
  });

  test('strings with escapes, and an unclosed one stays on its line', () {
    expect(kinds(js, r'"a\"b"'), [(TokenType.string, r'"a\"b"')]);

    final lines = tokenize(js, ["s = 'open", 'x']);
    expect(lines[0].last.type, TokenType.string);
    expect(lines[1].single.type, TokenType.identifier);
  });

  test('a template literal on one line, and across lines, with an escaped backtick', () {
    expect(kinds(js, r'`a\`b` + x').first, (TokenType.string, r'`a\`b`'));

    final lines = tokenize(js, ['s = `start', 'middle', 'end` + t']);
    expect(lines[1].single.type, TokenType.string);
    expect(lines[2].map((t) => t.type), [TokenType.string, TokenType.operator, TokenType.identifier]);
  });

  test('line and block comments, a block across lines too', () {
    expect(kinds(js, 'x // note').last, (TokenType.comment, '// note'));
    expect(kinds(js, '/* a */ x'), [(TokenType.comment, '/* a */'), (TokenType.identifier, 'x')]);

    final lines = tokenize(js, ['/* start', 'middle', 'end */ y']);
    expect(lines[1].single.type, TokenType.comment);
    expect(lines[2].map((t) => t.type), [TokenType.comment, TokenType.identifier]);
  });

  test('numbers, and empty input', () {
    expect(typeOf(js, 'x = 2.5;', '2.5'), TokenType.number);
    expect(kinds(js, ''), isEmpty);
  });
}
