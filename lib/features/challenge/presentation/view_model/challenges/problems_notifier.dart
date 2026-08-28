import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/repositories/problem_repository.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProblemsNotifier extends Notifier<AsyncValue<List<CodingProblem>>> {
  late final ProblemRepository _repository;

  @override
  AsyncValue<List<CodingProblem>> build() {
    _repository = ref.watch(problemRepositoryProvider);
    _load();
    return const AsyncLoading();
  }

  Future<void> _load() async {
    state = await AsyncValue.guard(() => _repository.getAllProblems());
  }

  void updateProblem(CodingProblem updated) {
    state = state.whenData(
      (problems) => [
        for (final problem in problems)
          // to update only widgets that are watching the problem that matches the id
          if (problem.problemId == updated.problemId) updated else problem,
      ],
    );
  }

  void deleteProblem(int problemId) {
    state =
        state.whenData((problems) => problems.where((problem) => problem.problemId != problemId).toList());
  }
}
