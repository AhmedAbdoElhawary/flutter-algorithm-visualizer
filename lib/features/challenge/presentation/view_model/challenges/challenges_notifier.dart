import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/repositories/problem_repository.dart';
import 'package:algorithm_visualizer/features/challenge/domain/usecases/grade_code_usecase.dart';
import 'package:algorithm_visualizer/features/challenge/domain/usecases/update_problem_solution_usecase.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'challenges_state.dart';

class ChallengesNotifier extends Notifier<ChallengesState> {
  static const filters = ProblemDifficulty.values;

  @override
  ChallengesState build() => ChallengesState.initial();

  ProblemRepository get _problemRepository => ref.read(problemRepositoryProvider);
  UpdateProblemSolutionUseCase get _updateProblemSolutionUseCase =>
      UpdateProblemSolutionUseCase(_problemRepository);

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
    ref.read(problemsProvider.notifier).updateProblem(updatedProblem);
  }

  Future<void> toggleBookmark(CodingProblem problem) async {
    final updated = problem.copyWith(isBookmarked: !problem.getIsBookmarked);
    await _problemRepository.updateProblem(updated);
    ref.read(problemsProvider.notifier).updateProblem(updated);
  }

  Future<void> deleteProblem(int problemId) async {
    await _problemRepository.deleteProblem(problemId);
    ref.read(problemsProvider.notifier).deleteProblem(problemId);
  }
}
