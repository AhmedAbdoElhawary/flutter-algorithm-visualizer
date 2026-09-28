import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart' show EditorLanguage;
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/editor/code_controller.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/editor/editor_code_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  late CodeController attached;

  Widget card({EditorLanguage language = EditorLanguage.dart, int? highlightedLine, bool running = false}) =>
      Scaffold(
        body: SingleChildScrollView(
          child: EditorCodeCard(
            fileName: 'solution.dart',
            initialCode: 'int f() {\n  return 1;\n}',
            highlightedLine: highlightedLine,
            running: running,
            language: language,
            onControllerAttached: (controller) => attached = controller,
          ),
        ),
      );

  testWidgets('shows the file name and hands its editor over with the starting code', (tester) async {
    await pumpApp(tester, card());

    expect(find.text('solution.dart'), findsOneWidget);
    expect(attached.text, 'int f() {\n  return 1;\n}');
  });

  testWidgets('grows with the code instead of scrolling inside', (tester) async {
    await pumpApp(tester, card());
    final before = tester.getSize(find.byType(EditorCodeCard)).height;

    attached.text = '${attached.text}\n// one more line';
    await tester.pump();

    expect(tester.getSize(find.byType(EditorCodeCard)).height, greaterThan(before));
  });

  testWidgets('Python indents by four, everything else by two', (tester) async {
    await pumpApp(tester, card());
    expect(attached.config.tabSize, 2);

    await tester.pumpWidget(const SizedBox());
    await pumpApp(tester, card(language: EditorLanguage.python));
    expect(attached.config.tabSize, 4);
  });

  testWidgets('switching language keeps the same editor and changes its indent', (tester) async {
    final language = ValueNotifier(EditorLanguage.dart);
    addTearDown(language.dispose);
    await pumpApp(
      tester,
      ValueListenableBuilder(valueListenable: language, builder: (context, value, child) => card(language: value)),
    );
    final first = attached;

    language.value = EditorLanguage.python;
    await tester.pump();

    expect(attached, same(first));
    expect(first.config.tabSize, 4);
  });

  testWidgets('the running line lights up, and clears when the run ends', (tester) async {
    final line = ValueNotifier<int?>(null);
    addTearDown(line.dispose);
    await pumpApp(
      tester,
      ValueListenableBuilder(valueListenable: line, builder: (context, value, child) => card(highlightedLine: value)),
    );
    expect(attached.highlightedLines, isEmpty);

    line.value = 2;
    await tester.pump();
    expect(attached.highlightedLines.keys, [1], reason: 'the editor stores lines from zero');

    line.value = -1;
    await tester.pump();
    expect(attached.highlightedLines, isEmpty);
  });

  testWidgets('while running the code cannot be edited', (tester) async {
    await pumpApp(tester, card(running: true));

    await tester.enterText(find.byType(EditableText), 'changed');
    await tester.pump();

    expect(attached.text, 'int f() {\n  return 1;\n}');
  });

  testWidgets('fits a small screen with large text', (tester) async {
    await pumpApp(tester, card(), screen: ScreenSize.smallPhone, textScale: 2);

    expect(tester.takeException(), isNull);
  });
}
