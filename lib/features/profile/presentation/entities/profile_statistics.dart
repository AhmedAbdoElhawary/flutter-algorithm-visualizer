import 'practice_history_entry.dart';
import 'recent_submission.dart';

class ProfileStatistics {
  const ProfileStatistics({
    required this.totalProblems,
    required this.solvedCount,
    required this.easySolved,
    required this.mediumSolved,
    required this.hardSolved,
    required this.easyTotal,
    required this.mediumTotal,
    required this.hardTotal,
    required this.totalAttempts,
    required this.correctAttempts,
    required this.accuracyRate,
    required this.bookmarkedCount,
    required this.currentStreak,
    required this.bestStreak,
    required this.weeklyActivity,
    required this.heatmapData,
    required this.categorySolved,
    required this.recentSubmissions,
    required this.practiceHistory,
  });

  final int totalProblems;

  final int solvedCount;
  final int easySolved;
  final int mediumSolved;
  final int hardSolved;

  final int easyTotal;
  final int mediumTotal;
  final int hardTotal;

  final int totalAttempts;
  final int correctAttempts;
  final double accuracyRate;

  final int bookmarkedCount;

  final int currentStreak;
  final int bestStreak;

  final List<int> weeklyActivity;
  final List<int> heatmapData;

  final Map<String, int> categorySolved;

  final List<RecentSubmission> recentSubmissions;
  final List<PracticeHistoryEntry> practiceHistory;

  double get easyRatio => easyTotal == 0 ? 0 : easySolved / easyTotal;

  double get mediumRatio => mediumTotal == 0 ? 0 : mediumSolved / mediumTotal;

  double get hardRatio => hardTotal == 0 ? 0 : hardSolved / hardTotal;

  factory ProfileStatistics.empty() => ProfileStatistics(
        totalProblems: 0, solvedCount: 0, easySolved: 0, mediumSolved: 0, //
        hardSolved: 0, easyTotal: 0, mediumTotal: 0, hardTotal: 0, //
        totalAttempts: 0, correctAttempts: 0, accuracyRate: 0, //
        bookmarkedCount: 0, currentStreak: 0, bestStreak: 0, //
        weeklyActivity: List<int>.filled(7, 0), //
        heatmapData: List<int>.filled(84, 0), //
        categorySolved: {}, recentSubmissions: [], practiceHistory: [], //
      );
}
