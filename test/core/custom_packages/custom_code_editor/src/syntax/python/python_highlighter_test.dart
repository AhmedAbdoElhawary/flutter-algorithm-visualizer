import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../highlight_test_support.dart';

void main() {
  const python = PythonTokenizer();

  test('keywords, builtins, names, operators and punctuation', () {
    expect(kinds(python, 'def f(xs): return len(xs) >= 2'), [
      (TokenType.keyword, 'def'),
      (TokenType.identifier, 'f'),
      (TokenType.punctuation, '('),
      (TokenType.identifier, 'xs'),
      (TokenType.punctuation, ')'),
      (TokenType.punctuation, ':'),
      (TokenType.keyword, 'return'),
      (TokenType.builtin, 'len'),
      (TokenType.punctuation, '('),
      (TokenType.identifier, 'xs'),
      (TokenType.punctuation, ')'),
      (TokenType.operator, '>='),
      (TokenType.number, '2'),
    ]);
  });

  test('strings with escapes, and an unclosed one stays on its line', () {
    expect(kinds(python, r"'it\'s'"), [(TokenType.string, r"'it\'s'")]);

    final lines = tokenize(python, ['s = "open', 'x']);
    expect(lines[0].last.type, TokenType.string);
    expect(lines[1].single.type, TokenType.identifier);
  });

  test('a triple-quoted string on one line, and across lines', () {
    expect(kinds(python, '"""doc""" x'), [(TokenType.string, '"""doc"""'), (TokenType.identifier, 'x')]);

    final lines = tokenize(python, ["s = '''start", 'middle', "end''' + t"]);
    expect(lines[1].single.type, TokenType.string);
    expect(lines[2].map((t) => t.type), [TokenType.string, TokenType.operator, TokenType.identifier]);
  });

  test('numbers and comments', () {
    expect(typeOf(python, 'x = 3.5', '3.5'), TokenType.number);
    expect(kinds(python, 'x  # note'), [(TokenType.identifier, 'x'), (TokenType.comment, '# note')]);
  });

  test('empty input, and anything unknown is plain', () {
    expect(kinds(python, ''), isEmpty);
    expect(kinds(python, r'$'), [(TokenType.plain, r'$')]);
  });
}
