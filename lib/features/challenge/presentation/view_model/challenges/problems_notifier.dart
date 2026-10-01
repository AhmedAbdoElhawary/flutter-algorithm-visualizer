import 'package:algorithm_visualizer/core/enums/app_settings_enum.dart';
import 'package:algorithm_visualizer/core/helpers/storage/app_settings/app_settings_cubit.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/repositories/problem_repository.dart';
import 'package:algorithm_visualizer/features/challenge/domain/usecases/grade_code_usecase.dart';
import 'package:algorithm_visualizer/features/challenge/domain/usecases/update_problem_solution_usecase.dart';
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
    if (!ref.mounted) return;

    final problems = await AsyncValue.guard(() => _repository.getAllProblems(arabic: arabic));
    if (!ref.mounted) return;
    state = problems;
  }

  // Saving lives here, not on the challenges page's notifier: that one is gone whenever its page is
  // closed, and the bookmarks page and the editor save too.

  Future<void> updateProblemSubmission(CodingProblem problem, CodeGradeResult result) async {
    final updated = await UpdateProblemSolutionUseCase(_repository).call(problem, result);
    _showSaved(updated);
  }

  Future<void> toggleBookmark(CodingProblem problem) async {
    final updated = problem.copyWith(isBookmarked: !problem.getIsBookmarked);
    await _repository.updateProblem(updated);
    _showSaved(updated);
  }

  Future<void> deleteProblem(int problemId) async {
    await _repository.deleteProblem(problemId);
    if (!ref.mounted) return;
    state = state.whenData((problems) => problems.where((problem) => problem.problemId != problemId).toList());
    ref.read(problemSyncProvider.notifier).refreshUnsyncedFlag();
  }

  void _showSaved(CodingProblem updated) {
    if (!ref.mounted) return;
    updateProblem(updated);
    ref.read(problemSyncProvider.notifier).refreshUnsyncedFlag();
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
}
