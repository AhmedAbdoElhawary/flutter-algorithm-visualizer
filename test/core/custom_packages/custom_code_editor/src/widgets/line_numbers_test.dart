import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  final theme = CodeEditorTheme.dark();

  Future<void> pumpNumbers(
    WidgetTester tester, {
    required int lines,
    int? active,
    int? error,
    Map<int, Color>? highlighted,
  }) async {
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    await pumpApp(
      tester,
      Align(
        alignment: Alignment.topLeft,
        child: LineNumbers(
          lineCount: lines,
          theme: theme,
          scrollController: scroll,
          lineHeight: 20,
          numbersPadding: 0,
          activeLine: active,
          errorLine: error,
          highlightedLines: highlighted,
        ),
      ),
    );
  }

  TextStyle styleOf(WidgetTester tester, String number) =>
      tester.widget<Text>(find.byWidgetPredicate((w) => w is Text && w.data!.trim() == number)).style!;

  testWidgets('one number per line, padded to the widest', (tester) async {
    await pumpNumbers(tester, lines: 10);

    expect(find.text(' 1'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
  });

  testWidgets('the current line stands out from the rest', (tester) async {
    await pumpNumbers(tester, lines: 3, active: 1);

    expect(styleOf(tester, '2').color, theme.textStyle.color);
    expect(styleOf(tester, '1').color, theme.lineNumberStyle.color);
  });

  testWidgets('an error line is red and bold, and beats a highlight on the same line', (tester) async {
    await pumpNumbers(tester, lines: 3, error: 0, highlighted: {0: Colors.blue, 2: Colors.blue});

    expect(styleOf(tester, '1').color, theme.errorColor);
    expect(styleOf(tester, '1').fontWeight, FontWeight.bold);
    expect(styleOf(tester, '3').color, Colors.blue);
  });
}
