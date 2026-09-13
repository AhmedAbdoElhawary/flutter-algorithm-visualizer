import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/editor/editor_action_bar.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/editor/editor_code_card.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/editor/editor_test_case_card.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/editor/editor_title_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/problem_page_test_support.dart';

void main() {
  testWidgets('region order: title row above code card above test case card (SC-002)', (tester) async {
    final problem = buildGradableTestProblem(code: gradableWrongCode);
    await pumpEditorPage(tester, problem: problem);

    await tester.tap(find.text(StringsManager.runAndSubmit));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    final titleY = tester.getTopLeft(find.byType(EditorTitleRow)).dy;
    final codeY = tester.getTopLeft(find.byType(EditorCodeCard)).dy;
    final caseY = tester.getTopLeft(find.byType(EditorTestCaseCard)).dy;

    expect(titleY, lessThan(codeY));
    expect(codeY, lessThan(caseY));
  });

  testWidgets('the action bar stays inside the viewport (FR-004)', (tester) async {
    await pumpEditorPage(tester, problem: buildGradableTestProblem());

    final barRect = tester.getRect(find.byType(EditorActionBar));
    final screenHeight = tester.view.physicalSize.height / tester.view.devicePixelRatio;

    expect(barRect.bottom, lessThanOrEqualTo(screenHeight));
  });

  for (final size in [const Size(320, 720), const Size(430, 932), const Size(480, 1000)]) {
    testWidgets('no overflow at surface size $size (SC-008)', (tester) async {
      await pumpEditorPage(
        tester,
        problem: buildGradableTestProblem(),
        surfaceSize: size,
      );

      expect(tester.takeException(), isNull);
    });
  }
}
