import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/models/code_editor_config.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/utils/indentation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const twoSpaces = CodeEditorConfig(tabSize: 2);
  const tabs = CodeEditorConfig(useSpaces: false);

  test('the leading whitespace of a line, spaces or tabs', () {
    expect(Indentation.leadingWhitespaceOf('    return 1;'), '    ');
    expect(Indentation.leadingWhitespaceOf('\t\tx'), '\t\t');
    expect(Indentation.leadingWhitespaceOf('x'), '');
    expect(Indentation.leadingWhitespaceOf(''), '');
  });

  group('the next line keeps the indent, one level deeper after an opener', () {
    for (final (line, expected) in [
      ('  int x = 1;', '  '),
      ('  void f() {', '    '),
      ('  foo(', '    '),
      ('  xs = [', '    '),
      ('  def f(a):', '    '),
      ('  if x:  ', '    '),
      ('  case 1:', '    '),
      ('', ''),
    ]) {
      test('"$line"', () {
        expect(Indentation.nextLineIndent(line, line.length, twoSpaces), expected);
      });
    }

    test('only what is before the cursor counts', () {
      expect(Indentation.nextLineIndent('  f() {}', 5, twoSpaces), '  ');
    });

    test('tabs when the config says so', () {
      expect(Indentation.nextLineIndent('void f() {', 10, tabs), '\t');
    });
  });

  group('what Enter inserts', () {
    test('after an opener: a newline and a deeper indent, caret at its end', () {
      final insertion = Indentation.computeNewlineInsertion('  if (x) {', 10, twoSpaces);

      expect(insertion.text, '\n    ');
      expect(insertion.caretOffset, 5);
    });

    test('between a pair, the closer moves to its own line under the opener', () {
      final insertion = Indentation.computeNewlineInsertion('  f() {}', 7, twoSpaces);

      expect(insertion.text, '\n    \n  ');
      expect(insertion.caretOffset, 5);
    });

    test('between brackets that do not match, no split', () {
      final insertion = Indentation.computeNewlineInsertion('(]', 1, twoSpaces);

      expect(insertion.text, '\n  ');
    });

    test('a colon never splits a line, it only indents', () {
      final insertion = Indentation.computeNewlineInsertion('if x:)', 5, twoSpaces);

      expect(insertion.text, '\n  ');
    });

    test('with auto-indent off, a plain newline', () {
      const plain = CodeEditorConfig(autoIndent: false);
      final insertion = Indentation.computeNewlineInsertion('  {', 3, plain);

      expect(insertion.text, '\n');
      expect(insertion.caretOffset, 1);
    });
  });
}
