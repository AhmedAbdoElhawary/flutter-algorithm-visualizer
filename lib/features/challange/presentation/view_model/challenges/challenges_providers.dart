import 'package:algorithm_visualizer/core/storage/get_storage_service.dart';
import 'package:algorithm_visualizer/features/challange/data/data_sources/local/challenge_local_data_source.dart';
import 'package:algorithm_visualizer/features/challange/data/repositories/problem_repository_impl.dart';
import 'package:algorithm_visualizer/features/challange/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challange/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challange/domain/usecases/update_problem_solution_usecase.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

import 'challenges_notifier.dart';
import 'challenges_state.dart';

final challengesProvider = StateNotifierProvider.autoDispose<ChallengesNotifier, ChallengesState>((ref) {
  final repo = ProblemRepositoryImpl(ProblemLocalDataSource(GetStorageService(GetStorage())));
  return ChallengesNotifier(repo, UpdateProblemSolutionUseCase(repo));
});

final _challengeDatasetProvider = FutureProvider<List<CodingProblem>>(
  (ref) => ref.read(challengesProvider.notifier).getAllProblems(),
);

final filteredProblemsProvider = Provider<AsyncValue<List<CodingProblem>>>((ref) {
  final problemsAsync = ref.watch(_challengeDatasetProvider);
  final state = ref.watch(challengesProvider);

  return problemsAsync.whenData(
    (problems) {
      return problems.where((problem) {
        if (state.filter != null &&
            state.filter != ProblemDifficulty.none &&
            problem.difficulty != state.filter) {
          return false;
        }
        if (state.search.isNotEmpty && !problem.getName.toLowerCase().contains(state.search.toLowerCase())) {
          return false;
        }
        return true;
      }).toList();
    },
  );
});

final getProblemProvider = Provider.family<AsyncValue<CodingProblem?>, int>(
  (ref, problemId) {
    final problems = ref.watch(_challengeDatasetProvider);

    return problems.whenData(
      (problems) {
        if (problemId <= 0) return null;

        return problems.firstWhereOrNull((problem) => problem.problemId == problemId);
      },
    );
  },
);

final solvedCountProvider = Provider<AsyncValue<int>>((ref) {
  final problems = ref.watch(_challengeDatasetProvider);

  return problems.whenData((problems) => problems.where((problem) => problem.isSolved).length);
});

final difficultyCountProvider = Provider.family<AsyncValue<int>, ProblemDifficulty?>(
  (ref, filter) {
    final problems = ref.watch(_challengeDatasetProvider);

    return problems.whenData(
      (problems) {
        if (filter == null || filter == ProblemDifficulty.none) return problems.length;

        return problems.where((problem) => problem.difficulty == filter).length;
      },
    );
  },
);
