import 'package:algorithm_visualizer/core/enums/app_settings_enum.dart';
import 'package:algorithm_visualizer/core/helpers/storage/app_settings/app_settings_cubit.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/repositories/problem_repository.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProblemsNotifier extends Notifier<AsyncValue<List<CodingProblem>>> {
  ProblemRepository get _repository => ref.read(problemRepositoryProvider);

  @override
  AsyncValue<List<CodingProblem>> build() {
    final language = ref.watch(appSettingsProvider.select((state) => state.language));

    _arabic = language == LanguagesEnum.arabic;

    _load(arabic: _arabic);
    return const AsyncLoading();
  }

  bool _arabic = false;

  Future<void> reload() => _load(arabic: _arabic);

  Future<void> _load({required bool arabic}) async {
    /// only does work on the first launch of an account on this device
    await ref.read(problemSyncServiceProvider).downloadIfFirstRun();

    state = await AsyncValue.guard(() => _repository.getAllProblems(arabic: arabic));
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
