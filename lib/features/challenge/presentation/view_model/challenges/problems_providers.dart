import 'package:algorithm_visualizer/core/storage/get_storage_service.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/challenge_local_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/repositories/problem_repository_impl.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/repositories/problem_repository.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_notifier.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

final problemRepositoryProvider = Provider<ProblemRepository>((ref) {
  return ProblemRepositoryImpl(ProblemLocalDataSource(GetStorageService(GetStorage())));
});

final problemsProvider = NotifierProvider<ProblemsNotifier, AsyncValue<List<CodingProblem>>>(() {
  return ProblemsNotifier();
});

/// [getProblemProvider] it's register for problem id only not all problems
/// so, will notify only if the problem id changed
final getProblemProvider = Provider.family<AsyncValue<CodingProblem?>, int>((ref, problemId) {
  if (problemId <= 0) return const AsyncValue.data(null);
  return ref.watch(
    problemsProvider.select(
      (async) => async.whenData(
        (problems) => problems.firstWhereOrNull((problem) => problem.problemId == problemId),
      ),
    ),
  );
});

/// The number of solved problems. Notifies only when the count actually
/// changes (e.g. a failed attempt on an unsolved problem doesn't rebuild the
/// header's solved counter).
final solvedCountProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(
    problemsProvider.select(
      (async) => async.whenData((problems) => problems.where((problem) => problem.isSolved).length),
    ),
  );
});

final specificDifficultyCountProvider = Provider.family<AsyncValue<int>, ProblemDifficulty?>(
  (ref, filter) {
    return ref.watch(
      problemsProvider.select(
        (async) => async.whenData((problems) {
          if (filter == null || filter == ProblemDifficulty.none) return problems.length;
          return problems.where((problem) => problem.difficulty == filter).length;
        }),
      ),
    );
  },
);
