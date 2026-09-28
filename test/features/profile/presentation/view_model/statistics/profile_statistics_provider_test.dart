import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/profile/domain/entities/profile_statistics.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/statistics/profile_statistics_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

import '../../../../../helpers/test_data.dart';

void main() {
  test('returns calculated statistics when problems are loaded', () {
    final problems = [
      buildTestProblem(problemId: 1, difficulty: ProblemDifficulty.easy, problemStatus: ProblemStatus.solved),
      buildTestProblem(problemId: 2, difficulty: ProblemDifficulty.hard, problemStatus: ProblemStatus.attempted),
    ];

    final container = ProviderContainer(
      overrides: [
        problemsProvider.overrideWithBuild((ref, notifier) => AsyncValue.data(problems)),
      ],
    );
    addTearDown(container.dispose);

    final result = container.read(profileStatisticsProvider);

    expect(result.totalProblems, 2);
    expect(result.solvedCount, 1);
    expect(result.easyTotal, 1);
    expect(result.hardTotal, 1);
  });

  test('returns empty statistics while problems are loading', () {
    final container = ProviderContainer(
      overrides: [
        problemsProvider.overrideWithBuild((ref, notifier) => const AsyncValue.loading()),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(profileStatisticsProvider), _matchesEmptyStatistics());
  });

  test('returns empty statistics when loading problems fails', () {
    final container = ProviderContainer(
      overrides: [
        problemsProvider.overrideWithBuild(
          (ref, notifier) => AsyncValue.error(Exception('Failed to load problems'), StackTrace.current),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(profileStatisticsProvider), _matchesEmptyStatistics());
  });

  test('uses the ProfileStatisticsCalculator provider', () {
    final container = ProviderContainer(
      overrides: [
        problemsProvider.overrideWithBuild((ref, notifier) => AsyncValue.data([buildTestProblem()])),
        profileStatisticsCalculatorProvider.overrideWithValue(const _Doubling()),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(profileStatisticsProvider).totalProblems, 2);
  });
}

/// Proves the provider asks the calculator provider, not a calculator of its own.
class _Doubling extends ProfileStatisticsCalculator {
  const _Doubling();

  @override
  ProfileStatistics computeStats(problems, {DateTime? now}) =>
      super.computeStats([...problems, ...problems], now: now);
}

Matcher _matchesEmptyStatistics() {
  return predicate<ProfileStatistics>(
    (stats) =>
        stats.totalProblems == 0 &&
        stats.solvedCount == 0 &&
        stats.easySolved == 0 &&
        stats.mediumSolved == 0 &&
        stats.hardSolved == 0 &&
        stats.easyTotal == 0 &&
        stats.mediumTotal == 0 &&
        stats.hardTotal == 0 &&
        stats.totalAttempts == 0 &&
        stats.correctAttempts == 0 &&
        stats.accuracyRate == 0 &&
        stats.bookmarkedCount == 0 &&
        stats.currentStreak == 0 &&
        stats.bestStreak == 0 &&
        stats.weeklyActivity.length == 7 &&
        stats.weeklyActivity.every((value) => value == 0) &&
        stats.heatmapData.length == 84 &&
        stats.heatmapData.every((value) => value == 0) &&
        stats.categorySolved.isEmpty &&
        stats.recentSubmissions.isEmpty &&
        stats.practiceHistory.isEmpty,
    'is empty ProfileStatistics',
  );
}
