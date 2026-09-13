import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/similar_question.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/editor_page.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/problem_page.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/problem_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/problem_page_test_support.dart';

void main() {
  Future<void> tapTab(WidgetTester tester, String label) async {
    await tester.tap(find.widgetWithText(Tab, label));
    await tester.pumpAndSettle();
  }

  Future<void> tapSolveInEditor(WidgetTester tester) async {
    await tester.tap(find.text(StringsManager.solveInEditor));
    await tester.pumpAndSettle();
  }

  testWidgets('Solve in editor opens the editor for that problem and back returns (FR-011, FR-012)',
      (tester) async {
    final problem = buildTestProblem(problemId: 1, name: 'Two Sum');
    final router = await pumpProblemToEditorChain(tester, problems: [problem], rootProblemId: 1);

    expect(router.routerDelegate.currentConfiguration.matches.length, 1);
    expect(find.byType(ProblemPage), findsOneWidget);

    await tapSolveInEditor(tester);

    expect(router.routerDelegate.currentConfiguration.matches.length, 2);
    expect(find.byType(EditorPage), findsOneWidget);
    expect(find.text('Two Sum'), findsWidgets);

    router.pop();
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.matches.length, 1);
    expect(find.byType(ProblemPage), findsOneWidget);
    expect(find.byType(EditorPage), findsNothing);
  });

  testWidgets('the Similar-list path returns to the similar problem, not the original (US1 scenario 5)',
      (tester) async {
    final a = buildTestProblem(
      problemId: 1,
      name: 'Problem A',
      similarQuestions: const [SimilarQuestion(problemId: 2, name: 'Problem B', reason: 'r')],
    );
    final b = buildTestProblem(problemId: 2, name: 'Problem B');

    final router = await pumpProblemToEditorChain(tester, problems: [a, b], rootProblemId: 1);

    await tapTab(tester, StringsManager.similarQuestions);
    await tester.tap(find.byType(ProblemTile));
    await tester.pumpAndSettle();
    await tester.tap(find.text(StringsManager.solveWithArrow));
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.matches.length, 2);
    expect(find.text('Problem B'), findsOneWidget);

    await tapSolveInEditor(tester);

    expect(router.routerDelegate.currentConfiguration.matches.length, 3);
    expect(find.byType(EditorPage), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.matches.length, 2);
    expect(find.text('Problem B'), findsOneWidget);
    expect(find.byType(EditorPage), findsNothing);
  });
}
