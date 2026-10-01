import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart' show EditorLanguage;
import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/test_case.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/usecases/grade_code_usecase.dart';
import 'package:algorithm_visualizer/features/challenge/domain/usecases/update_problem_solution_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes/fake_problem_repository.dart';
import '../../../../helpers/test_data.dart';

void main() {
  late FakeProblemRepository repository;
  late UpdateProblemSolutionUseCase save;

  setUp(() {
    repository = FakeProblemRepository();
    save = UpdateProblemSolutionUseCase(repository);
  });

  CodeGradeResult graded({required bool passed, String code = 'code', EditorLanguage language = EditorLanguage.dart}) {
    return CodeGradeResult(
      allTestCaseResults: [TestCaseResult(input: '', expectedOutput: '', actualOutput: '', passed: passed)],
      totalCount: 1,
      code: code,
      language: language,
    );
  }

  ProblemSolutionStatusDTO oldRun(int i, {String language = 'dart'}) =>
      ProblemSolutionStatusDTO(code: 'old $i', isCorrect: false, submittedAt: DateTime(2026, 1, 1), language: language);

  test('a passing run solves the problem and is saved first, with its code and language', () async {
    final problem = buildTestProblem(isBookmarked: true, solutions: [oldRun(1)]);

    final updated = await save(problem, graded(passed: true, code: 'mine', language: EditorLanguage.python));

    expect(updated.problemStatus, ProblemStatus.solved);
    expect(updated.isBookmarked, isTrue);
    final latest = updated.getSolutionsStatus.first;
    expect(latest.code, 'mine');
    expect(latest.isCorrect, isTrue);
    expect(latest.languageKey, 'python');
    expect(latest.submittedAt, isNotNull);
    expect(updated.getSolutionsStatus[1].code, 'old 1');
    expect(repository.updated.single, same(updated));
  });

  test('a failing run marks it attempted', () async {
    final updated = await save(buildTestProblem(), graded(passed: false));

    expect(updated.problemStatus, ProblemStatus.attempted);
    expect(updated.getSolutionsStatus.single.isCorrect, isFalse);
  });

  group('the run limit', () {
    test('keeps only the newest ${UpdateProblemSolutionUseCase.maxSavedRuns}', () async {
      final problem = buildTestProblem(solutions: [for (var i = 1; i <= 60; i++) oldRun(i)]);

      final updated = await save(problem, graded(passed: false, code: 'newest'));

      final runs = updated.getSolutionsStatus;
      expect(runs, hasLength(UpdateProblemSolutionUseCase.maxSavedRuns));
      expect(runs.first.code, 'newest');
      expect(runs.last.code, 'old ${UpdateProblemSolutionUseCase.maxSavedRuns - 1}');
    });

    test('a language whose only draft is past the limit keeps it, so the editor can still reopen it', () async {
      final problem = buildTestProblem(
        solutions: [for (var i = 1; i <= 60; i++) oldRun(i), oldRun(61, language: 'javascript')],
      );

      final updated = await save(problem, graded(passed: false));

      final runs = updated.getSolutionsStatus;
      expect(runs, hasLength(UpdateProblemSolutionUseCase.maxSavedRuns + 1));
      expect(runs.last.code, 'old 61');
      expect(runs.where((run) => run.languageKey == 'dart'), hasLength(UpdateProblemSolutionUseCase.maxSavedRuns));
    });

    test('under the limit nothing is dropped', () async {
      final problem = buildTestProblem(solutions: [for (var i = 1; i <= 3; i++) oldRun(i)]);

      final updated = await save(problem, graded(passed: false));

      expect(updated.getSolutionsStatus, hasLength(4));
    });
  });
}
