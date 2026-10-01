import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  CodeController controllerFor(String text) {
    final controller = CodeController(text: text, config: const CodeEditorConfig(tabSize: 2));
    addTearDown(controller.dispose);
    return controller;
  }

  Future<void> pumpEditor(WidgetTester tester, CodeEditor editor) =>
      pumpApp(tester, Scaffold(body: SizedBox(height: 300, child: editor)));

  final gutter = find.byType(LineNumbers);
  int lineCount(WidgetTester tester) => tester.widget<LineNumbers>(gutter).lineCount;

  testWidgets('typing goes into the controller, and the line numbers follow the lines', (tester) async {
    final controller = controllerFor('int a;');
    await pumpEditor(tester, CodeEditor(controller: controller));
    expect(lineCount(tester), 1);

    await tester.enterText(find.byType(EditableText), 'int a;\nint b;\nint c;');
    await tester.pump();

    expect(controller.text, 'int a;\nint b;\nint c;');
    expect(lineCount(tester), 3);
  });

  testWidgets('the line with the caret is the active one', (tester) async {
    final controller = controllerFor('a\nb\nc');
    await pumpEditor(tester, CodeEditor(controller: controller));

    controller.selection = const TextSelection.collapsed(offset: 3);
    await tester.pump();

    expect(tester.widget<LineNumbers>(gutter).activeLine, 1);
  });

  testWidgets('an error line and highlighted lines reach the gutter and the text area', (tester) async {
    final controller = controllerFor('int add(')
      ..problem = const ProblemData(
        functionSignature: 'int add(int a, int b)',
        testCases: [ProblemTestCase(input: 'a=1, b=2', expectedOutput: '3')],
      );
    await pumpEditor(tester, CodeEditor(controller: controller));

    controller.runAllTests();
    controller.highlightLines([0], Colors.blue);
    await tester.pump();

    expect(tester.widget<LineNumbers>(gutter).errorLine, 0);
    expect(find.byType(Positioned), findsWidgets);
  });

  testWidgets('with line numbers off, there is no gutter', (tester) async {
    await pumpEditor(
      tester,
      CodeEditor(controller: controllerFor('int a;'), config: const CodeEditorConfig(showLineNumbers: false)),
    );

    expect(gutter, findsNothing);
    expect(find.byType(EditableText), findsOneWidget);
  });

  testWidgets('a config and a theme given to the widget reach the controller', (tester) async {
    final controller = controllerFor('int a;');
    final theme = CodeEditorTheme.light();

    await pumpEditor(
      tester,
      CodeEditor(controller: controller, config: const CodeEditorConfig(tabSize: 8), theme: theme),
    );

    expect(controller.config.tabSize, 8);
    expect(controller.theme, same(theme));
  });

  testWidgets('read only lets nothing be typed', (tester) async {
    await pumpEditor(tester, CodeEditor(controller: controllerFor('int a;'), readOnly: true));

    expect(tester.widget<EditableText>(find.byType(EditableText)).readOnly, isTrue);
  });

  testWidgets('swapping the controller listens to the new one only', (tester) async {
    final first = controllerFor('a');
    final second = controllerFor('a\nb\nc\nd');
    await pumpEditor(tester, CodeEditor(controller: first));

    await pumpEditor(tester, CodeEditor(controller: second));
    expect(lineCount(tester), 4);

    first.text = 'x\ny';
    await tester.pump();
    expect(lineCount(tester), 4);
  });

  testWidgets('the gutter scrolls with the code', (tester) async {
    final controller = controllerFor(List.generate(60, (i) => 'int v$i = $i;').join('\n'));
    await pumpEditor(tester, CodeEditor(controller: controller));

    final gutterScroll = tester.widget<LineNumbers>(gutter).scrollController;
    final codeScroll = tester
        .stateList<ScrollableState>(find.byType(Scrollable))
        .firstWhere((s) => s.position.axis == Axis.vertical && s.widget.controller != gutterScroll);

    codeScroll.position.jumpTo(200);
    await tester.pump();

    expect(gutterScroll.offset, 200);
  });

  testWidgets('a focus node from outside is used and left for its owner', (tester) async {
    final node = FocusNode();
    addTearDown(node.dispose);
    await pumpEditor(tester, CodeEditor(controller: controllerFor('a'), focusNode: node, autofocus: true));
    await tester.pump();

    expect(node.hasFocus, isTrue);

    await pumpApp(tester, const SizedBox());
    expect(() => node.requestFocus(), returnsNormally);
  });

  testWidgets('a long press selects a word, as in any text field', (tester) async {
    final controller = controllerFor('hello world');
    await pumpEditor(tester, CodeEditor(controller: controller));

    await tester.longPress(find.byType(EditableText));
    await tester.pumpAndSettle();

    expect(controller.selection.isCollapsed, isFalse);
  });
}
