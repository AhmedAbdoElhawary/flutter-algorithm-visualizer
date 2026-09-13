import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/test_case.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/editor/editor_code_card.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/editor/editor_test_case_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/problem_page_test_support.dart';

void main() {
  Future<void> runAndSettle(WidgetTester tester) async {
    await tester.tap(find.text(StringsManager.runAndSubmit));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  testWidgets('the primary label flips to running and disables mid-run, then reverts (FR-016)',
      (tester) async {
    await pumpEditorPage(tester, problem: buildGradableTestProblem(code: gradableWrongCode));

    expect(find.text(StringsManager.runAndSubmit), findsOneWidget);
    expect(find.text(StringsManager.running), findsNothing);

    await tester.tap(find.text(StringsManager.runAndSubmit));
    await tester.pump();

    expect(find.text(StringsManager.running), findsOneWidget);
    expect(find.text(StringsManager.runAndSubmit), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text(StringsManager.runAndSubmit), findsOneWidget);
    expect(find.text(StringsManager.running), findsNothing);
  });

  testWidgets('the marked line appears during the run and clears at the end (FR-017)', (tester) async {
    await pumpEditorPage(tester, problem: buildGradableTestProblem(code: gradableWrongCode));

    await tester.tap(find.text(StringsManager.runAndSubmit));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    final midRunCard = tester.widget<EditorCodeCard>(find.byType(EditorCodeCard));
    expect(midRunCard.highlightedLine != null && midRunCard.highlightedLine! > 0, isTrue);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    final afterRunCard = tester.widget<EditorCodeCard>(find.byType(EditorCodeCard));
    expect(afterRunCard.highlightedLine == null || afterRunCard.highlightedLine == -1, isTrue);
  });

  testWidgets('the test case card is absent before the first run and present after (FR-023)',
      (tester) async {
    await pumpEditorPage(tester, problem: buildGradableTestProblem(code: gradableWrongCode));

    expect(find.byType(EditorTestCaseCard), findsNothing);

    await runAndSettle(tester);

    expect(find.byType(EditorTestCaseCard), findsOneWidget);
  });

  testWidgets('failing rows precede passing rows and show the returned value (FR-018)', (tester) async {
    final problem = buildGradableTestProblem(code: gradableWrongCode);
    await pumpEditorPage(tester, problem: problem);

    await runAndSettle(tester);

    expect(find.textContaining(StringsManager.gotPrefix), findsOneWidget);
    expect(find.textContaining('0 / 1'), findsOneWidget);
  });

  testWidgets('a whole-run failure replaces the per-case rows entirely (FR-019)', (tester) async {
    // No function signature attached -> ProblemRunner reports a whole-run
    // "Invalid function signature" error instead of per-case results.
    final problem = buildTestProblem(problemId: 1, name: 'Broken').copyWith(
      testCases: const [TestCase(input: 'a=1, b=2', expectedOutput: '3')],
      defaultCode: {'dart': gradableWrongCode},
    );
    await pumpEditorPage(tester, problem: problem);

    await runAndSettle(tester);

    expect(find.byType(EditorTestCaseCard), findsOneWidget);
    expect(find.textContaining('Invalid function signature'), findsOneWidget);
    expect(find.textContaining(StringsManager.gotPrefix), findsNothing);
  });

  testWidgets('a second run replaces the first result rather than stacking (FR-022)', (tester) async {
    await pumpEditorPage(tester, problem: buildGradableTestProblem(code: gradableWrongCode));

    await runAndSettle(tester);
    expect(find.byType(EditorTestCaseCard), findsOneWidget);
    expect(find.textContaining('0 / 1'), findsOneWidget);

    await runAndSettle(tester);

    expect(find.byType(EditorTestCaseCard), findsOneWidget);
    expect(find.textContaining('0 / 1'), findsOneWidget);
  });

  testWidgets('popping mid-run throws nothing and writes no state afterwards (FR-022)', (tester) async {
    await pumpEditorPage(tester, problem: buildGradableTestProblem(code: gradableWrongCode));

    await tester.tap(find.text(StringsManager.runAndSubmit));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    // Tear down the whole widget tree mid-run.
    await tester.pumpWidget(const SizedBox.shrink());

    // Let the run's remaining 100ms ticks fire with nothing mounted.
    await tester.pump(const Duration(seconds: 2));

    expect(tester.takeException(), isNull);
  });
}
