import 'package:algorithm_visualizer/features/profile/domain/entities/profile_statistics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ProfileStatistics stats({
    int easy = 0,
    int easyTotal = 0,
    int medium = 0,
    int mediumTotal = 0,
    int hard = 0,
    int hardTotal = 0,
  }) {
    final empty = ProfileStatistics.empty();
    return ProfileStatistics(
      totalProblems: easyTotal + mediumTotal + hardTotal,
      solvedCount: easy + medium + hard,
      easySolved: easy,
      mediumSolved: medium,
      hardSolved: hard,
      easyTotal: easyTotal,
      mediumTotal: mediumTotal,
      hardTotal: hardTotal,
      totalAttempts: 0,
      correctAttempts: 0,
      accuracyRate: 0,
      bookmarkedCount: 0,
      currentStreak: 0,
      bestStreak: 0,
      weeklyActivity: empty.weeklyActivity,
      heatmapData: empty.heatmapData,
      categorySolved: const {},
      recentSubmissions: const [],
      practiceHistory: const [],
    );
  }

  test('empty has a zero for every count, a week of days and 12 weeks of heatmap', () {
    final empty = ProfileStatistics.empty();

    expect(empty.totalProblems, 0);
    expect(empty.solvedCount, 0);
    expect(empty.accuracyRate, 0);
    expect(empty.currentStreak, 0);
    expect(empty.weeklyActivity, List.filled(7, 0));
    expect(empty.heatmapData, List.filled(84, 0));
    expect(empty.categorySolved, isEmpty);
    expect(empty.recentSubmissions, isEmpty);
    expect(empty.practiceHistory, isEmpty);
  });

  test('each ratio is solved over total', () {
    final s = stats(easy: 1, easyTotal: 4, medium: 1, mediumTotal: 2, hard: 3, hardTotal: 3);

    expect(s.easyRatio, 0.25);
    expect(s.mediumRatio, 0.5);
    expect(s.hardRatio, 1);
  });

  test('a difficulty with no problems has a zero ratio, not a division by zero', () {
    final s = stats();

    expect(s.easyRatio, 0);
    expect(s.mediumRatio, 0);
    expect(s.hardRatio, 0);
  });
}
