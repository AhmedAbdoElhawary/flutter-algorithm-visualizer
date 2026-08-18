import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BracketUtils', () {
    test('identifies openers and closers', () {
      expect(BracketUtils.isOpener('('), isTrue);
      expect(BracketUtils.isCloser(')'), isTrue);
      expect(BracketUtils.isOpener(')'), isFalse);
    });

    test('quotes are recognized', () {
      expect(BracketUtils.isQuote('"'), isTrue);
      expect(BracketUtils.isQuote("'"), isTrue);
      expect(BracketUtils.isQuote('a'), isFalse);
    });

    test('closingFor returns the matching character', () {
      expect(BracketUtils.closingFor('('), ')');
      expect(BracketUtils.closingFor('{'), '}');
      expect(BracketUtils.closingFor('"'), '"');
      expect(BracketUtils.closingFor('x'), isNull);
    });

    test('isMatchingPair validates pairs correctly', () {
      expect(BracketUtils.isMatchingPair('(', ')'), isTrue);
      expect(BracketUtils.isMatchingPair('(', ']'), isFalse);
    });
  });

  group('CodeController bracket auto-close', () {
    test('typing an opening bracket inserts the matching close', () {
      final controller = CodeController();
      controller.selection = const TextSelection.collapsed(offset: 0);
      controller.value = const TextEditingValue(
        text: '(',
        selection: TextSelection.collapsed(offset: 1),
      );
      expect(controller.text, '()');
      expect(controller.selection.baseOffset, 1);
    });

    test('typing the matching close types-over instead of duplicating', () {
      final controller = CodeController(text: '()');
      controller.selection = const TextSelection.collapsed(offset: 1);
      controller.value = const TextEditingValue(
        text: '())',
        selection: TextSelection.collapsed(offset: 2),
      );
      expect(controller.text, '()');
      expect(controller.selection.baseOffset, 2);
    });

    test('backspace deletes an empty bracket pair as a unit', () {
      final controller = CodeController(text: '()');
      controller.selection = const TextSelection.collapsed(offset: 1);
      controller.value = const TextEditingValue(
        text: ')',
        selection: TextSelection.collapsed(offset: 0),
      );
      expect(controller.text, '');
      expect(controller.selection.baseOffset, 0);
    });

    test('auto-pairing can be disabled via config', () {
      final controller = CodeController(
        config: const CodeEditorConfig(autoCloseBrackets: false),
      );
      controller.selection = const TextSelection.collapsed(offset: 0);
      controller.value = const TextEditingValue(
        text: '(',
        selection: TextSelection.collapsed(offset: 1),
      );
      expect(controller.text, '(');
    });
  });

  group('CodeController smart indent on Enter', () {
    test('pressing Enter inside braces splits and indents the new line', () {
      // Cursor sits between '{' (index 10) and '}' (index 11).
      final controller = CodeController(text: 'if (true) {}');
      controller.selection = const TextSelection.collapsed(offset: 11);
      controller.value = const TextEditingValue(
        text: 'if (true) {\n}',
        selection: TextSelection.collapsed(offset: 12),
      );
      // Default config uses a 4-space indent unit.
      expect(controller.text, 'if (true) {\n    \n}');
      expect(controller.selection.baseOffset, 16);
    });

    test('pressing Enter on a plain line preserves indentation', () {
      final controller = CodeController(text: '    foo();');
      controller.selection = const TextSelection.collapsed(offset: 10);
      controller.value = const TextEditingValue(
        text: '    foo();\n',
        selection: TextSelection.collapsed(offset: 11),
      );
      expect(controller.text, '    foo();\n    ');
    });
  });
}
