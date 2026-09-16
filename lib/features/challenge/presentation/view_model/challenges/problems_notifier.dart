import 'package:algorithm_visualizer/core/enums/app_settings_enum.dart';
import 'package:algorithm_visualizer/core/helpers/storage/app_settings/app_settings_cubit.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/view_model/auth_providers.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/repositories/problem_repository.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProblemsNotifier extends Notifier<AsyncValue<List<CodingProblem>>> {
  // Riverpod keeps the same Notifier instance across rebuilds and calls build()
  // again on it, so this is read lazily rather than cached in a `late final`
  // field that would throw on the second build (e.g. after a guest sign up
  // invalidates this provider).
  ProblemRepository get _repository => ref.read(problemRepositoryProvider);

  @override
  AsyncValue<List<CodingProblem>> build() {
    /// Watched, not read: switching language has to re-read the dataset,
    /// because the problem statements themselves come from the asset rather
    /// than from a lookup table a text widget could redo on rebuild.
    final language = ref.watch(appSettingsProvider.select((state) => state.language));

    _load(arabic: language == LanguagesEnum.arabic);
    return const AsyncLoading();
  }

  Future<void> _load({required bool arabic}) async {
    await _retryPendingMigration();
    state = await AsyncValue.guard(() => _repository.getAllProblems(arabic: arabic));
  }

  /// Finishes a hand over that was interrupted, typically by signing up while
  /// offline. Runs before the load so the problems are read back from Firestore
  /// once the local copy has been delivered.
  Future<void> _retryPendingMigration() async {
    final guestDataService = ref.read(guestDataServiceProvider);

    if (!guestDataService.hasPendingMigration) return;
    if (!ref.read(problemRemoteDataSourceProvider).isSignedIn) return;

    await guestDataService.migrateToAccount();
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
