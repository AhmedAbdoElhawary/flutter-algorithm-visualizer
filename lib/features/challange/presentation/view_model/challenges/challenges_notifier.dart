import 'package:algorithm_visualizer/features/challange/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challange/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challange/domain/repositories/problem_repository.dart';
import 'package:algorithm_visualizer/features/challange/domain/usecases/grade_code_usecase.dart';
import 'package:algorithm_visualizer/features/challange/domain/usecases/update_problem_solution_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'challenges_state.dart';
import 'problems_notifier.dart';

class ChallengesNotifier extends StateNotifier<ChallengesState> {
  static const filters = ProblemDifficulty.values;

  ChallengesNotifier(this._problemRepository, this._updateProblemSolutionUseCase, this._ref)
      : super(ChallengesState.initial());
  final ProblemRepository _problemRepository;
  final UpdateProblemSolutionUseCase _updateProblemSolutionUseCase;
  final Ref _ref;

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

  Future<void> updateProblem(CodingProblem problem, CodeGradeResult result) async {
    final updatedProblem = await _updateProblemSolutionUseCase.call(problem, result);
    _ref.read(problemsProvider.notifier).updateProblem(updatedProblem);
  }

  Future<void> toggleBookmark(CodingProblem problem) async {
    final updated = problem.copyWith(isBookmarked: !problem.getIsBookmarked);
    await _problemRepository.updateProblem(updated);
    _ref.read(problemsProvider.notifier).updateProblem(updated);
  }

  Future<void> deleteProblem(int problemId) async {
    await _problemRepository.deleteProblem(problemId);
    _ref.read(problemsProvider.notifier).deleteProblem(problemId);
  }
}
