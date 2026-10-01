import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart'
    show EditorLanguageX;
import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/repositories/problem_repository.dart';

import 'grade_code_usecase.dart' show CodeGradeResult;

class UpdateProblemSolutionUseCase {
  final ProblemRepository repository;
  UpdateProblemSolutionUseCase(this.repository);

  /// Each run keeps its full code, here and in the Firestore document, which caps out at 1 MB.
  static const int maxSavedRuns = 50;

  Future<CodingProblem> call(CodingProblem problem, CodeGradeResult result) async {
    final dto = ProblemStorageDTO.fromJson(problem.toJson());

    final status = ProblemSolutionStatusDTO(
      code: result.code,
      isCorrect: result.allPassed,
      submittedAt: DateTime.now(),
      language: result.language.datasetKey,
    );

    final runs = [status, ...?dto.solutionsStatus];
    final kept = runs.take(maxSavedRuns).toList();

    // Past the cap, each language still keeps its newest draft for the editor to reopen.
    for (final run in runs.skip(maxSavedRuns)) {
      if (!kept.any((k) => k.languageKey == run.languageKey)) kept.add(run);
    }

    final updatedProblem = problem.copyWith(
      problemStatus: result.allPassed ? ProblemStatus.solved : ProblemStatus.attempted,
      solutionsStatus: kept,
      isBookmarked: null,
    );
    await repository.updateProblem(updatedProblem);

    return updatedProblem;
  }
}
