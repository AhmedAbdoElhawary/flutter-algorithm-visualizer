import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/celebration_page.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/problem_page_test_support.dart';

void main() {
  // Not `pumpAndSettle`: a passing run may navigate to `CelebrationPage`,
  // whose ring animation repeats forever and would never let it settle.
  Future<void> runAndSettle(WidgetTester tester) async {
    await tester.tap(find.text(StringsManager.runAndSubmit));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));
  }

  testWidgets('an all-pass run records the submission and navigates to celebration (FR-020)',
      (tester) async {
    final repository = FakeProblemRepository();
    final problem = buildGradableTestProblem();

    await pumpEditorPage(tester, problem: problem, repository: repository);
    await runAndSettle(tester);

    expect(find.byType(CelebrationPage), findsOneWidget);
    expect(repository.updated, hasLength(1));
    expect(repository.updated.single.isThereAnyCorrectCodeSaved, isTrue);
  });

  testWidgets(
      'a failing run on a problem with a correct solution already saved does not overwrite it (research R5)',
      (tester) async {
    final repository = FakeProblemRepository();
    // getCode() prefers a saved solution over defaultCode (FR-013), so the
    // editor opens showing the already-correct saved code. Typing over it
    // with the wrong code is what actually exercises "a failing run on a
    // problem with a correct solution already saved".
    final problem = buildGradableTestProblem(
      solutionsStatus: const [
        ProblemSolutionStatusDTO(code: gradableCorrectCode, isCorrect: true),
      ],
    );

    await pumpEditorPage(tester, problem: problem, repository: repository);
    await tester.enterText(find.byType(EditableText), gradableWrongCode);
    await tester.pump();
    await runAndSettle(tester);

    expect(find.byType(CelebrationPage), findsNothing);
    expect(repository.updated, isEmpty);
  });

  testWidgets('a problem with no test cases reads 0 / 0 passed and never celebrates (SC-006)', (tester) async {
    final repository = FakeProblemRepository();
    final problem = buildGradableTestProblem(testCases: const []);

    await pumpEditorPage(tester, problem: problem, repository: repository);
    await runAndSettle(tester);

    expect(find.textContaining('0 / 0'), findsOneWidget);
    expect(find.byType(CelebrationPage), findsNothing);
    // The run→record guard (research R5, carried verbatim) only skips
    // recording when a correct solution is already saved — it has no
    // separate "zero test cases" rule, so a fresh problem's 0/0 attempt is
    // still recorded (as `attempted`, not `solved`). Adding a skip here
    // would be a new special case FR-022 forbids.
    expect(repository.updated, hasLength(1));
    expect(repository.updated.single.isThereAnyCorrectCodeSaved, isFalse);
  });
}
