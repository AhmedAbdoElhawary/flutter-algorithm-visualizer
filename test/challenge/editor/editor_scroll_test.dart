import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/editor/editor_test_case_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/problem_page_test_support.dart';

void main() {
  testWidgets(
      'the result card scrolls into view on its own once the run finishes, from an off-screen offset (FR-019a, SC-005)',
      (tester) async {
    // Padding pushes the code card (and everything after it) below the fold
    // at the surface's default scroll offset.
    final problem = buildGradableTestProblem(
      code: gradableWrongCode,
      name: List.generate(3, (_) => 'Very long problem name that wraps').join(' '),
    );

    await pumpEditorPage(tester, problem: problem);

    await tester.tap(find.text(StringsManager.runAndSubmit));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(EditorTestCaseCard), findsOneWidget);

    // ensureVisible already ran inside pumpAndSettle above (post-frame
    // callback fired the moment isRunning flipped false) — confirm the
    // card actually landed inside the viewport, with no further gesture.
    final renderBox = tester.renderObject<RenderBox>(find.byType(EditorTestCaseCard));
    final topLeft = renderBox.localToGlobal(Offset.zero);
    final size = tester.view.physicalSize / tester.view.devicePixelRatio;

    expect(topLeft.dy, greaterThanOrEqualTo(0));
    expect(topLeft.dy, lessThan(size.height));
  });
}
