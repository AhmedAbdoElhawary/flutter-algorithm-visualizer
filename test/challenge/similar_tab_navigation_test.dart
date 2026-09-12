import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/similar_question.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/problem_page.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/problem_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/problem_page_test_support.dart';

// NOTE: `CustomBackButton` reads `context.canPop()`, and in this isolated
// (shell-less) test harness that already reports `true` on the very first,
// un-pushed page (see `problem_page_test.dart`'s pre-existing "deep scroll"
// test) - so it cannot distinguish "root" from "stacked" here. Depth and
// content assertions below (route-match count, which problem's name is on
// screen) are the reliable signal in this harness; verifying the back
// affordance itself is absent at the shell root needs the full
// `StatefulShellRoute`, which is out of scope for this widget-level suite.
void main() {
  Future<void> tapTab(WidgetTester tester, String label) async {
    await tester.tap(find.widgetWithText(Tab, label));
    await tester.pumpAndSettle();
  }

  Future<void> expandAndSolve(WidgetTester tester) async {
    await tapTab(tester, StringsManager.similarQuestions);
    await tester.tap(find.byType(ProblemTile));
    await tester.pumpAndSettle();
    await tester.tap(find.text(StringsManager.solveWithArrow));
    await tester.pumpAndSettle();
  }

  testWidgets('Solve on a Similar-tab row stacks a new problem page (FR-018a, C2.6b, C2.6c)',
      (tester) async {
    final a = buildTestProblem(
      problemId: 1,
      name: 'Problem A',
      similarQuestions: const [SimilarQuestion(problemId: 2, name: 'Problem B', reason: 'r')],
    );
    final b = buildTestProblem(problemId: 2, name: 'Problem B');

    final router = await pumpProblemPageChain(tester, problems: [a, b], rootProblemId: 1);

    expect(router.routerDelegate.currentConfiguration.matches.length, 1);
    expect(find.text('Problem A'), findsOneWidget);

    await expandAndSolve(tester);

    expect(router.routerDelegate.currentConfiguration.matches.length, 2);
    expect(find.text('Problem B'), findsOneWidget);
    expect(find.byType(ProblemPage), findsOneWidget);
  });

  testWidgets('A -> B -> A stacks three separate pages rather than collapsing the chain (FR-021a, C2.6g)',
      (tester) async {
    final a = buildTestProblem(
      problemId: 1,
      name: 'Problem A',
      similarQuestions: const [SimilarQuestion(problemId: 2, name: 'Problem B', reason: 'r')],
    );
    final b = buildTestProblem(
      problemId: 2,
      name: 'Problem B',
      similarQuestions: const [SimilarQuestion(problemId: 1, name: 'Problem A', reason: 'r')],
    );

    final router = await pumpProblemPageChain(tester, problems: [a, b], rootProblemId: 1);

    await expandAndSolve(tester);
    expect(find.text('Problem B'), findsOneWidget);

    await expandAndSolve(tester);
    expect(find.text('Problem A'), findsOneWidget);

    expect(router.routerDelegate.currentConfiguration.matches.length, 3);

    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('Problem B'), findsOneWidget);
    expect(router.routerDelegate.currentConfiguration.matches.length, 2);

    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('Problem A'), findsOneWidget);
    expect(router.routerDelegate.currentConfiguration.matches.length, 1);
  });

  testWidgets('a 4-deep chain works with no depth cap and no replace in the code path (FR-021, C2.6f)',
      (tester) async {
    final problems = [
      buildTestProblem(
        problemId: 1,
        name: 'Problem 1',
        similarQuestions: const [SimilarQuestion(problemId: 2, name: 'Problem 2', reason: 'r')],
      ),
      buildTestProblem(
        problemId: 2,
        name: 'Problem 2',
        similarQuestions: const [SimilarQuestion(problemId: 3, name: 'Problem 3', reason: 'r')],
      ),
      buildTestProblem(
        problemId: 3,
        name: 'Problem 3',
        similarQuestions: const [SimilarQuestion(problemId: 4, name: 'Problem 4', reason: 'r')],
      ),
      buildTestProblem(problemId: 4, name: 'Problem 4'),
    ];

    final router = await pumpProblemPageChain(tester, problems: problems, rootProblemId: 1);

    for (var i = 2; i <= 4; i++) {
      await expandAndSolve(tester);
      expect(find.text('Problem $i'), findsOneWidget);
    }

    expect(router.routerDelegate.currentConfiguration.matches.length, 4);
  });
}
