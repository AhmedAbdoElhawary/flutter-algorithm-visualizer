import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../highlight_test_support.dart';

void main() {
  const dart = DartTokenizer();

  test('keywords, builtin types, names, operators and punctuation', () {
    expect(kinds(dart, 'final int x = a >= b;'), [
      (TokenType.keyword, 'final'),
      (TokenType.builtin, 'int'),
      (TokenType.identifier, 'x'),
      (TokenType.operator, '='),
      (TokenType.identifier, 'a'),
      (TokenType.operator, '>='),
      (TokenType.identifier, 'b'),
      (TokenType.punctuation, ';'),
    ]);
  });

  test('strings in either quote, escapes included', () {
    expect(kinds(dart, r"'it\'s'"), [(TokenType.string, r"'it\'s'")]);
    expect(kinds(dart, '"a" + b'), [
      (TokenType.string, '"a"'),
      (TokenType.operator, '+'),
      (TokenType.identifier, 'b'),
    ]);
  });

  test('an unclosed string runs to the end of the line and does not leak into the next', () {
    final lines = tokenize(dart, ["var s = 'open", 'int b;']);

    expect(lines[0].last.type, TokenType.string);
    expect(lines[1].first.type, TokenType.builtin);
  });

  test('numbers, hex included', () {
    expect(typeOf(dart, 'x = 42;', '42'), TokenType.number);
    expect(typeOf(dart, 'x = 3.14;', '3.14'), TokenType.number);
    expect(typeOf(dart, 'x = 0xFF;', '0xFF'), TokenType.number);
  });

  test('a line comment takes the rest of the line', () {
    expect(kinds(dart, 'x; // note'), [
      (TokenType.identifier, 'x'),
      (TokenType.punctuation, ';'),
      (TokenType.comment, '// note'),
    ]);
  });

  test('a block comment on one line, and across lines', () {
    expect(kinds(dart, '/* a */ x'), [(TokenType.comment, '/* a */'), (TokenType.identifier, 'x')]);

    final lines = tokenize(dart, ['x /* start', 'middle', 'end */ y']);
    expect(lines[1], [const Token(type: TokenType.comment, text: 'middle', start: 0, end: 6)]);
    expect(lines[2].map((t) => t.type), [TokenType.comment, TokenType.identifier]);
  });

  test('empty input, and anything unknown is plain', () {
    expect(kinds(dart, ''), isEmpty);
    expect(kinds(dart, '@'), [(TokenType.plain, '@')]);
  });

  test('positions match the text', () {
    const line = '  return x;';
    for (final token in tokenize(dart, [line]).single) {
      expect(line.substring(token.start, token.end), token.text);
    }
  });
}
