import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CodeController controller;

  CodeController editor(String text, {CodeEditorConfig config = const CodeEditorConfig(tabSize: 2)}) {
    controller = CodeController(text: text, config: config)
      ..selection = TextSelection.collapsed(offset: text.length);
    addTearDown(controller.dispose);
    return controller;
  }

  /// Types [keys] one at a time at the caret, the way a keyboard does.
  void type(String keys) {
    for (final key in keys.split('')) {
      final at = controller.selection.baseOffset;
      controller.value = TextEditingValue(
        text: controller.text.substring(0, at) + key + controller.text.substring(at),
        selection: TextSelection.collapsed(offset: at + 1),
      );
    }
  }

  void backspace() {
    final at = controller.selection.baseOffset;
    controller.value = TextEditingValue(
      text: controller.text.substring(0, at - 1) + controller.text.substring(at),
      selection: TextSelection.collapsed(offset: at - 1),
    );
  }

  /// The text with a `|` where the caret is.
  String withCaret() {
    final at = controller.selection.baseOffset;
    return '${controller.text.substring(0, at)}|${controller.text.substring(at)}';
  }

  group('pairs', () {
    test('an opening bracket brings its closer, caret in between', () {
      editor('f');
      type('(');
      expect(withCaret(), 'f(|)');
    });

    test('typing the closer steps over it instead of doubling it', () {
      editor('f');
      type('(x)');
      expect(withCaret(), 'f(x)|');
    });

    test('a comparison does not gain a stray >', () {
      editor('if (a ');
      type('< b');
      expect(withCaret(), 'if (a < b|');
    });

    test('quotes pair, and step over their closer', () {
      editor('s = ');
      type('"hi"');
      expect(withCaret(), 's = "hi"|');
    });

    test('an apostrophe inside a word is left alone', () {
      editor('# don');
      type("'t");
      expect(withCaret(), "# don't|");
    });

    test('backspace between an empty pair removes both', () {
      editor('f');
      type('[');
      backspace();
      expect(withCaret(), 'f|');
    });

    test('backspace after a lone opener removes only it', () {
      editor('f(x');
      controller.selection = const TextSelection.collapsed(offset: 2);
      backspace();
      expect(withCaret(), 'f|x');
    });

    test('with auto-close off, nothing is added', () {
      editor('f', config: const CodeEditorConfig(autoCloseBrackets: false));
      type('(');
      expect(withCaret(), 'f(|');
    });
  });

  group('Enter', () {
    test('keeps the indent of the line', () {
      editor('  int a;');
      type('\n');
      expect(withCaret(), '  int a;\n  |');
    });

    test('indents after {, and after : for Python', () {
      editor('void f() ');
      type('{\n');
      expect(withCaret(), 'void f() {\n  |\n}');

      editor('def f():', config: const CodeEditorConfig());
      type('\n');
      expect(withCaret(), 'def f():\n    |');
    });

    test('drops the spaces left at the end of the line', () {
      editor('int a;   ');
      type('\n');
      expect(controller.text, 'int a;\n');
    });

    test('with auto-indent off, a plain newline', () {
      editor('  {', config: const CodeEditorConfig(autoIndent: false));
      type('\n');
      expect(withCaret(), '  {\n|');
    });
  });

  test('text being composed by the keyboard is not rewritten', () {
    editor('f');
    controller.value = const TextEditingValue(
      text: 'f(',
      selection: TextSelection.collapsed(offset: 2),
      composing: TextRange(start: 1, end: 2),
    );
    expect(controller.text, 'f(');
  });

  test('pasting a block is taken as is', () {
    editor('');
    controller.value = const TextEditingValue(text: 'f(x) {', selection: TextSelection.collapsed(offset: 6));
    expect(controller.text, 'f(x) {');
  });

  group('highlights', () {
    test('highlightLine takes the line as the grader reports it, one-based', () {
      editor('a\nb\nc');
      var notified = 0;
      controller.addListener(() => notified++);

      controller.highlightLine(2, Colors.red);
      controller.highlightLine(0, Colors.red);

      expect(controller.highlightedLines, {1: Colors.red});
      expect(notified, 1);
    });

    test('many lines at once, then one removed, then all cleared', () {
      editor('a\nb\nc');
      var notified = 0;
      controller.addListener(() => notified++);

      controller.highlightLines([0, 2], Colors.blue);
      controller.unhighlightLine(0);
      controller.unhighlightLine(1);
      expect(controller.highlightedLines, {2: Colors.blue});

      controller.clearHighlights();
      controller.clearHighlights();
      expect(controller.highlightedLines, isEmpty);
      expect(notified, 3, reason: 'removing or clearing nothing does not notify');
    });
  });

  group('grading', () {
    const problem = ProblemData(
      functionSignature: 'int add(int a, int b)',
      testCases: [ProblemTestCase(input: 'a=1, b=2', expectedOutput: '3')],
    );

    test('with no problem attached, there is nothing to grade', () {
      editor('int add(int a, int b) => a + b;');

      expect(controller.runAllTests(), isNull);
    });

    test('a passing run is kept, with no error line', () {
      editor('int add(int a, int b) => a + b;').problem = problem;

      final result = controller.runAllTests()!;

      expect(result.allPassed, isTrue);
      expect(controller.lastTestRunResult, same(result));
      expect(controller.errorLine, isNull);
    });

    test('code that does not compile marks an error line, and the next edit clears it', () {
      editor('int add(int a, int b) {').problem = problem;

      controller.runAllTests();
      expect(controller.errorLine, isNotNull);

      type(' ');
      expect(controller.errorLine, isNull);
    });

    test('clearError removes the mark without an edit', () {
      editor('int add(').problem = problem;
      controller.runAllTests();
      var notified = 0;
      controller.addListener(() => notified++);

      controller.clearError();
      controller.clearError();

      expect(controller.errorLine, isNull);
      expect(notified, 1);
    });
  });

  group('colouring', () {
    testWidgets('with no language, the text is one plain span', (tester) async {
      editor('int a;');
      late TextSpan span;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            span = controller.buildTextSpan(context: context, withComposing: false);
            return const SizedBox();
          },
        ),
      );

      expect(span.toPlainText(), 'int a;');
      expect(span.children, isNull);
    });

    testWidgets('with a language, keywords get their own colour', (tester) async {
      editor('int a;').setTokenizer(const DartTokenizer());
      late TextSpan span;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            span = controller.buildTextSpan(context: context, withComposing: false);
            return const SizedBox();
          },
        ),
      );

      expect(span.toPlainText(), 'int a;');
      final colours = <Color?>{};
      span.visitChildren((child) {
        if (child is TextSpan && (child.text?.trim().isNotEmpty ?? false)) colours.add(child.style?.color);
        return true;
      });
      expect(colours.length, greaterThan(1));
    });
  });

  test('document gives the text by lines', () {
    editor('a\nb');

    expect(controller.document.lines, ['a', 'b']);
  });
}
