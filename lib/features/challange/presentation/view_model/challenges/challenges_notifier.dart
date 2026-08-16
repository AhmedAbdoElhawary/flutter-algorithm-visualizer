import 'package:algorithm_visualizer/features/challange/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challange/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challange/domain/repositories/problem_repository.dart';
import 'package:algorithm_visualizer/features/challange/domain/usecases/grade_code_usecase.dart';
import 'package:algorithm_visualizer/features/challange/domain/usecases/update_problem_solution_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'challenges_state.dart';

class ChallengesNotifier extends StateNotifier<ChallengesState> {
  static const filters = ProblemDifficulty.values;

  ChallengesNotifier(this._problemRepository, this._updateProblemSolutionUseCase)
      : super(ChallengesState.initial());
  final ProblemRepository _problemRepository;
  final UpdateProblemSolutionUseCase _updateProblemSolutionUseCase;
  void setFilter(ProblemDifficulty filter) => state = state.copyWith(filter: filter);

  void setSearch(String query) => state = state.copyWith(search: query);

  void clearSearch() => state = state.copyWith(search: '');

  void toggleExpanded(int problemId) {
    if (state.expandedId == problemId) {
      state = state.copyWith(expandedId: 0);
    } else {
      state = state.copyWith(expandedId: problemId);
    }
  }

  Future<List<CodingProblem>> getAllProblems() async {
    return await _problemRepository.getAllProblems();
  }

  Future<void> updateProblem(CodingProblem problem, CodeGradeResult result) async {
    return await _updateProblemSolutionUseCase.call(problem, result);
  }

  Future<void> deleteProblem(int problemId) async {
    return await _problemRepository.deleteProblem(problemId);
  }
}
