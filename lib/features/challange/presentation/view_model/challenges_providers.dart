import 'package:algorithm_visualizer/core/storage/get_storage_service.dart';
import 'package:algorithm_visualizer/features/challange/data/data_sources/local/challenge_local_data_source.dart';
import 'package:algorithm_visualizer/features/challange/data/repositories/problem_repository_impl.dart';
import 'package:algorithm_visualizer/features/challange/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challange/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challange/domain/repositories/problem_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

import 'challenges_notifier.dart';

final _challengeRepositoryProvider = Provider<ProblemRepository>(
  (ref) => ProblemRepositoryImpl(ProblemLocalDataSource(GetStorageService(GetStorage()))),
);

final challengeDatasetProvider = FutureProvider<List<CodingProblem>>(
  (ref) {
    final dataSource = ref.read(_challengeRepositoryProvider);

    return dataSource.getAllProblems();
  },
);

final problemsProvider = Provider<AsyncValue<List<CodingProblem>>>((ref) {
  final problemsAsync = ref.watch(challengeDatasetProvider);
  final state = ref.watch(challengesProvider);

  return problemsAsync.whenData(
    (problems) {
      return problems.where((problem) {
        if (state.filter != null && problem.difficulty != state.filter) return false;

        if (state.search.isNotEmpty && !problem.getName.toLowerCase().contains(state.search.toLowerCase())) {
          return false;
        }
        return true;
      }).toList();
    },
  );
});

/// todo: make it actual data not [problemId]
final solvedCountProvider = Provider<AsyncValue<int>>((ref) {
  final problems = ref.watch(challengeDatasetProvider);

  return problems.whenData(
    (problems) {
      return problems.where((problem) => problem.problemId == 1).length;
    },
  );
});

final difficultyCountProvider = Provider.family<AsyncValue<int>, ProblemDifficulty?>(
  (ref, filter) {
    final problems = ref.watch(challengeDatasetProvider);

    return problems.whenData(
      (problems) {
        if (filter == null) {
          return problems.length;
        }

        return problems.where((problem) => problem.difficulty == filter).length;
      },
    );
  },
);
