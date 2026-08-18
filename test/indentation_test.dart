import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const config = CodeEditorConfig(tabSize: 2);

  group('Indentation.leadingWhitespaceOf', () {
    test('returns leading spaces', () {
      expect(Indentation.leadingWhitespaceOf('    foo'), '    ');
    });

    test('returns empty string when no indentation', () {
      expect(Indentation.leadingWhitespaceOf('foo'), '');
    });
  });

  group('Indentation.computeNewlineInsertion', () {
    test('preserves indentation on a plain line', () {
      final result = Indentation.computeNewlineInsertion('  foo();', 8, config);
      expect(result.text, '\n  ');
      expect(result.caretOffset, 3);
    });

    test('increases indentation after an opening brace', () {
      final result = Indentation.computeNewlineInsertion('if (true) {', 11, config);
      expect(result.text, '\n  ');
    });

    test('splits {|} into three lines with extra indent inside', () {
      final result = Indentation.computeNewlineInsertion('{}', 1, config);
      expect(result.text, '\n  \n');
      expect(result.caretOffset, 3);
    });

    test('respects tabSize', () {
      final wide = Indentation.computeNewlineInsertion('if (true) {', 11, config.copyWith(tabSize: 4));
      expect(wide.text, '\n    ');
    });

    test('returns a bare newline when autoIndent is disabled', () {
      final result = Indentation.computeNewlineInsertion(
        'if (true) {',
        11,
        config.copyWith(autoIndent: false),
      );
      expect(result.text, '\n');
      expect(result.caretOffset, 1);
    });
  });
}
