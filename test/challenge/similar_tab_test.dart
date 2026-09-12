import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/similar_question.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/bookmark_button.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/problem_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/problem_page_test_support.dart';

void main() {
  Future<void> tapTab(WidgetTester tester, String label) async {
    await tester.tap(find.widgetWithText(Tab, label));
    await tester.pumpAndSettle();
  }

  testWidgets('an unresolvable similar-question id renders no row and no gap (FR-023, C2.4c)',
      (tester) async {
    final root = buildTestProblem(
      problemId: 1,
      similarQuestions: const [
        SimilarQuestion(problemId: null, name: 'null id', reason: 'r'),
        SimilarQuestion(problemId: 0, name: 'zero id', reason: 'r'),
        SimilarQuestion(problemId: -5, name: 'negative id', reason: 'r'),
        SimilarQuestion(problemId: 999, name: 'unknown id', reason: 'r'),
        SimilarQuestion(problemId: 2, name: 'Valid Pair', reason: 'r'),
      ],
    );
    final valid = buildTestProblem(problemId: 2, name: 'Valid Pair');

    await pumpProblemPage(tester, problem: root, problemId: 1, extraProblems: [valid]);

    await tapTab(tester, StringsManager.similarQuestions);

    expect(find.byType(ProblemTile), findsOneWidget);
    expect(find.text('Valid Pair'), findsOneWidget);
  });

  testWidgets('all-unresolvable similar questions show the empty state (FR-024, C2.4d)', (tester) async {
    final root = buildTestProblem(
      problemId: 1,
      similarQuestions: const [
        SimilarQuestion(problemId: null, name: 'null id', reason: 'r'),
        SimilarQuestion(problemId: -1, name: 'negative id', reason: 'r'),
        SimilarQuestion(problemId: 42, name: 'unknown id', reason: 'r'),
      ],
    );

    await pumpProblemPage(tester, problem: root, problemId: 1);

    await tapTab(tester, StringsManager.similarQuestions);

    expect(find.byType(ProblemTile), findsNothing);
    expect(find.text(StringsManager.noSimilarQuestionsYet), findsOneWidget);
  });

  testWidgets('a problem with no similar questions at all shows the empty state', (tester) async {
    final root = buildTestProblem(problemId: 1, similarQuestions: const []);

    await pumpProblemPage(tester, problem: root, problemId: 1);

    await tapTab(tester, StringsManager.similarQuestions);

    expect(find.text(StringsManager.noSimilarQuestionsYet), findsOneWidget);
  });

  testWidgets('tapping a Similar-tab row expands it in place without navigating (Story 3 §2, C2.4e)',
      (tester) async {
    final root = buildTestProblem(
      problemId: 1,
      similarQuestions: const [SimilarQuestion(problemId: 2, name: 'Valid Pair', reason: 'r')],
    );
    final valid = buildTestProblem(problemId: 2, name: 'Valid Pair');

    await pumpProblemPage(tester, problem: root, problemId: 1, extraProblems: [valid]);

    await tapTab(tester, StringsManager.similarQuestions);

    expect(find.byType(BookmarkButton), findsNothing);

    await tester.tap(find.byType(ProblemTile));
    await tester.pumpAndSettle();

    expect(find.byType(BookmarkButton), findsOneWidget);
  });
}
