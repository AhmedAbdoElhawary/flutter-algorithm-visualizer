import 'package:algorithm_visualizer/core/storage/get_storage_service.dart';
import 'package:algorithm_visualizer/features/challange/data/data_sources/local/challenge_local_data_source.dart';
import 'package:algorithm_visualizer/features/challange/data/repositories/problem_repository_impl.dart';
import 'package:algorithm_visualizer/features/challange/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challange/domain/repositories/problem_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

final problemRepositoryProvider = Provider<ProblemRepository>((ref) {
  return ProblemRepositoryImpl(ProblemLocalDataSource(GetStorageService(GetStorage())));
});

/// The app-wide problem cache: the merged asset + local-solution list.
///
/// Owns the fetched list so consumers can patch a single problem in place
/// (via [_ProblemsNotifier.updateProblem]) instead of re-fetching everything.
/// Non-`autoDispose`: this is the source of truth every screen reads from.
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

  /// Replaces the single matching problem (everything else keeps its instance),
  /// so only widgets watching that problem are notified of a change.
  void updateProblem(CodingProblem updated) {
    state = state.whenData(
      (problems) => [
        for (final problem in problems)
          if (problem.problemId == updated.problemId) updated else problem,
      ],
    );
  }

  void deleteProblem(int problemId) {
    state = state.whenData(
      (problems) => problems.where((problem) => problem.problemId != problemId).toList(),
    );
  }
}
