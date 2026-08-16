import 'package:algorithm_visualizer/features/challange/data/models/problem_storage.dart';
import 'package:algorithm_visualizer/features/challange/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challange/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challange/domain/repositories/problem_repository.dart';

import 'grade_code_usecase.dart' show CodeGradeResult;

class UpdateProblemSolutionUseCase {
  final ProblemRepository repository;
  UpdateProblemSolutionUseCase(this.repository);

  Future<void> call(CodingProblem problem, CodeGradeResult result) async {
    final dto = ProblemStorageDTO.fromJson(problem.toJson());

    final status = ProblemSolutionStatusDTO(
      code: result.code,
      allTestCaseResults: result.allTestCaseResults,
      isCorrect: result.allPassed,
    );

    final solution = dto.solutionsStatus ?? [];

    final re = problem.copyWith(
      problemStatus: result.allPassed ? ProblemStatus.solved : ProblemStatus.attempted,
      solutionsStatus: [status, ...solution],
      isBookmarked: null,
    );
    await repository.updateProblem(re);
  }
}
