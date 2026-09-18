import 'package:algorithm_visualizer/core/logging/firebase_log_config.dart';
import 'package:algorithm_visualizer/core/storage/storage_providers.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/challenge_local_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/unsynced_problems.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/remote/challenge_remote_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/remote/logging_challenge_remote_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/repositories/problem_repository_impl.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/repositories/problem_repository.dart';
import 'package:algorithm_visualizer/features/challenge/domain/services/problem_sync_service.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_notifier.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/sync/problem_sync_notifier.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/sync/problem_sync_state.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final problemLocalDataSourceProvider = Provider<ProblemLocalDataSource>((ref) {
  return ProblemLocalDataSource(ref.watch(localStorageProvider));
});

final problemRemoteDataSourceProvider = Provider<ProblemRemoteDataSource>((ref) {
  final source = ProblemRemoteDataSourceImpl();
  return FirebaseLogConfig.enabled ? LoggingProblemRemoteDataSource(source) : source;
});

final unsyncedProblemsProvider = Provider<UnsyncedProblems>((ref) {
  return UnsyncedProblems(ref.watch(localStorageProvider));
});

final problemRepositoryProvider = Provider<ProblemRepository>((ref) {
  return ProblemRepositoryImpl(
    ref.watch(problemLocalDataSourceProvider),
    ref.watch(problemRemoteDataSourceProvider),
    ref.watch(unsyncedProblemsProvider),
  );
});

final problemSyncServiceProvider = Provider<ProblemSyncService>((ref) {
  return ProblemSyncService(
    localDataSource: ref.watch(problemLocalDataSourceProvider),
    unsyncedProblems: ref.watch(unsyncedProblemsProvider),
    remoteDataSource: ref.watch(problemRemoteDataSourceProvider),
    storage: ref.watch(localStorageProvider),
  );
});

final problemSyncProvider = NotifierProvider<ProblemSyncNotifier, ProblemSyncState>(() {
  return ProblemSyncNotifier();
});

final problemsProvider = NotifierProvider<ProblemsNotifier, AsyncValue<List<CodingProblem>>>(() {
  return ProblemsNotifier();
});

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

final solvedCountProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(
    problemsProvider.select(
      (async) => async.whenData((problems) => problems.where((problem) => problem.isSolved).length),
    ),
  );
});

final similarProblemIdsProvider = Provider.family<List<int>, CodingProblem>((ref, problem) {
  final problems = ref.read(problemsProvider).value ?? const [];
  final knownIds = problems.map((p) => p.problemId).whereType<int>().toSet();

  return problem.getSimilarQuestions
      .map((question) => question.problemId)
      .where((id) => id != null && id > 0 && knownIds.contains(id))
      .cast<int>()
      .toList(growable: false);
});
