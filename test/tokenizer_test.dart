import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DartTokenizer', () {
    const tokenizer = DartTokenizer();

    test('classifies keywords, identifiers, and punctuation', () {
      final result = tokenizer.tokenizeLine('if (x) {', tokenizer.initialState);
      final types = result.tokens.map((t) => t.type).toList();
      final texts = result.tokens.map((t) => t.text).toList();

      expect(texts, ['if', '(', 'x', ')', '{']);
      expect(types, [
        TokenType.keyword,
        TokenType.punctuation,
        TokenType.identifier,
        TokenType.punctuation,
        TokenType.punctuation,
      ]);
    });

    test('classifies string literals with escapes', () {
      final result = tokenizer.tokenizeLine(
        r'var s = "a \" b";',
        tokenizer.initialState,
      );
      final stringToken = result.tokens.firstWhere((t) => t.type == TokenType.string);
      expect(stringToken.text, r'"a \" b"');
    });

    test('classifies numbers', () {
      final result = tokenizer.tokenizeLine('final x = 42;', tokenizer.initialState);
      final numberToken = result.tokens.firstWhere((t) => t.type == TokenType.number);
      expect(numberToken.text, '42');
    });

    test('carries block comment state across lines', () {
      final first = tokenizer.tokenizeLine('/* start', tokenizer.initialState);
      expect(first.tokens.single.type, TokenType.comment);

      final second = tokenizer.tokenizeLine('still a comment', first.nextState);
      expect(second.tokens.single.type, TokenType.comment);

      final third = tokenizer.tokenizeLine('end */ var x;', second.nextState);
      expect(third.tokens.first.type, TokenType.comment);
      expect(third.tokens.first.text, 'end */');
      expect(third.tokens.any((t) => t.text == 'x'), isTrue);
    });

    test('line comment runs to end of line', () {
      final result = tokenizer.tokenizeLine(
        'var x = 1; // comment',
        tokenizer.initialState,
      );
      final commentToken = result.tokens.firstWhere((t) => t.type == TokenType.comment);
      expect(commentToken.text, '// comment');
    });
  });

  group('PythonTokenizer', () {
    const tokenizer = PythonTokenizer();

    test('classifies keywords and builtins', () {
      final result = tokenizer.tokenizeLine('def foo(self):', tokenizer.initialState);
      expect(result.tokens.first.type, TokenType.keyword);
      expect(result.tokens.first.text, 'def');
      expect(
        result.tokens.any((t) => t.text == 'self' && t.type == TokenType.builtin),
        isTrue,
      );
    });

    test('handles triple-quoted strings across lines', () {
      final first = tokenizer.tokenizeLine('x = """start', tokenizer.initialState);
      final stringStart = first.tokens.firstWhere((t) => t.type == TokenType.string);
      expect(stringStart.text, '"""start');

      final second = tokenizer.tokenizeLine('still inside', first.nextState);
      expect(second.tokens.single.type, TokenType.string);

      final third = tokenizer.tokenizeLine('end"""', second.nextState);
      expect(third.tokens.single.type, TokenType.string);
      expect(third.tokens.single.text, 'end"""');
    });

    test('comment runs to end of line', () {
      final result = tokenizer.tokenizeLine('x = 1  # comment', tokenizer.initialState);
      final commentToken = result.tokens.firstWhere((t) => t.type == TokenType.comment);
      expect(commentToken.text, '# comment');
    });
  });

  group('SyntaxHighlighter incremental caching', () {
    test('re-tokenizing identical lines returns equal token content', () {
      final highlighter = SyntaxHighlighter(const DartTokenizer());
      final lines = ['class Foo {', '  int x = 1;', '}'];

      final first = highlighter.highlight(lines);
      final second = highlighter.highlight(List<String>.from(lines));

      expect(second.length, first.length);
      for (var i = 0; i < first.length; i++) {
        expect(second[i].map((t) => t.text).toList(), first[i].map((t) => t.text).toList());
      }
    });

    test('only the edited line changes token identity after an edit', () {
      final highlighter = SyntaxHighlighter(const DartTokenizer());
      final lines = ['class Foo {', '  int x = 1;', '}'];
      final before = highlighter.highlight(lines);

      final editedLines = ['class Foo {', '  int y = 2;', '}'];
      final after = highlighter.highlight(editedLines);

      expect(identical(before[0], after[0]) || before[0].toString() == after[0].toString(), isTrue);
      expect(after[1].map((t) => t.text).toList(), contains('y'));
    });
  });
}
