import 'package:algorithm_visualizer/core/storage/get_storage_service.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/challenge_local_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/repositories/problem_repository_impl.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/repositories/problem_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

final problemRepositoryProvider = Provider<ProblemRepository>((ref) {
  return ProblemRepositoryImpl(ProblemLocalDataSource(GetStorageService(GetStorage())));
});

final problemsProvider = NotifierProvider<_ProblemsNotifier, AsyncValue<List<CodingProblem>>>(() {
  return _ProblemsNotifier();
});

class _ProblemsNotifier extends Notifier<AsyncValue<List<CodingProblem>>> {
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
