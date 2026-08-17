import 'package:algorithm_visualizer/features/challange/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challange/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challange/presentation/view_model/challenges/problems_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecentSubmission {
  const RecentSubmission({
    required this.problemId,
    required this.problemName,
    required this.difficulty,
    required this.isCorrect,
    required this.submittedAt,
  });

  final int problemId;
  final String problemName;
  final ProblemDifficulty difficulty;
  final bool isCorrect;
  final DateTime submittedAt;
}

class PracticeHistoryEntry {
  const PracticeHistoryEntry({
    required this.problemId,
    required this.problemName,
    required this.difficulty,
    required this.lastResult,
    required this.lastSubmittedAt,
    required this.attempts,
  });

  final int problemId;
  final String problemName;
  final ProblemDifficulty difficulty;
  final bool lastResult;
  final DateTime lastSubmittedAt;
  final List<RecentSubmission> attempts;
}

class ProfileStats {
  const ProfileStats({
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
}

final profileStatsProvider = Provider<ProfileStats>((ref) {
  final asyncProblems = ref.watch(problemsProvider);
  return asyncProblems.when(
    data: _computeStats,
    loading: () => ProfileStats(
      totalProblems: 0, solvedCount: 0, easySolved: 0, mediumSolved: 0,
      hardSolved: 0, easyTotal: 0, mediumTotal: 0, hardTotal: 0,
      totalAttempts: 0, correctAttempts: 0, accuracyRate: 0,
      bookmarkedCount: 0, currentStreak: 0, bestStreak: 0,
      weeklyActivity: [0, 0, 0, 0, 0, 0, 0],
      heatmapData: List<int>.filled(84, 0),
      categorySolved: {}, recentSubmissions: [], practiceHistory: [],
    ),
    error: (_, __) => ProfileStats(
      totalProblems: 0, solvedCount: 0, easySolved: 0, mediumSolved: 0,
      hardSolved: 0, easyTotal: 0, mediumTotal: 0, hardTotal: 0,
      totalAttempts: 0, correctAttempts: 0, accuracyRate: 0,
      bookmarkedCount: 0, currentStreak: 0, bestStreak: 0,
      weeklyActivity: [0, 0, 0, 0, 0, 0, 0],
      heatmapData: List<int>.filled(84, 0),
      categorySolved: {}, recentSubmissions: [], practiceHistory: [],
    ),
  );
});

ProfileStats _computeStats(List<CodingProblem> problems) {
  var solvedCount = 0;
  var easySolved = 0;
  var mediumSolved = 0;
  var hardSolved = 0;
  var easyTotal = 0;
  var mediumTotal = 0;
  var hardTotal = 0;
  var totalAttempts = 0;
  var correctAttempts = 0;
  var bookmarkedCount = 0;
  final categorySolved = <String, int>{};
  final submissions = <RecentSubmission>[];

  for (final problem in problems) {
    final diff = problem.getDifficulty;
    final solved = problem.isSolved;
    final bookmarked = problem.getIsBookmarked;

    if (diff == ProblemDifficulty.easy) easyTotal++;
    if (diff == ProblemDifficulty.medium) mediumTotal++;
    if (diff == ProblemDifficulty.hard) hardTotal++;

    if (solved) {
      solvedCount++;
      if (diff == ProblemDifficulty.easy) easySolved++;
      if (diff == ProblemDifficulty.medium) mediumSolved++;
      if (diff == ProblemDifficulty.hard) hardSolved++;
    }

    if (bookmarked) bookmarkedCount++;

    final cat = problem.getCategory;
    if (cat.isNotEmpty && solved) {
      categorySolved[cat] = (categorySolved[cat] ?? 0) + 1;
    }

    for (final solution in problem.getSolutionsStatus) {
      totalAttempts++;
      if (solution.isCorrect == true) correctAttempts++;
      if (solution.submittedAt != null) {
        submissions.add(RecentSubmission(
          problemId: problem.getProblemId,
          problemName: problem.getName,
          difficulty: diff,
          isCorrect: solution.isCorrect ?? false,
          submittedAt: solution.submittedAt!,
        ));
      }
    }
  }

  submissions.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  final recent = submissions.take(8).toList();

  final practiceHistory = _computePracticeHistory(submissions);

  final accuracyRate = totalAttempts == 0 ? 0.0 : correctAttempts / totalAttempts;

  final (currentStreak, bestStreak) = _computeStreaks(submissions);
  final weeklyActivity = _computeWeekly(submissions);
  final heatmapData = _computeHeatmap(submissions);

  return ProfileStats(
    totalProblems: problems.length,
    solvedCount: solvedCount,
    easySolved: easySolved,
    mediumSolved: mediumSolved,
    hardSolved: hardSolved,
    easyTotal: easyTotal,
    mediumTotal: mediumTotal,
    hardTotal: hardTotal,
    totalAttempts: totalAttempts,
    correctAttempts: correctAttempts,
    accuracyRate: accuracyRate,
    bookmarkedCount: bookmarkedCount,
    currentStreak: currentStreak,
    bestStreak: bestStreak,
    weeklyActivity: weeklyActivity,
    heatmapData: heatmapData,
    categorySolved: categorySolved,
    recentSubmissions: recent,
    practiceHistory: practiceHistory,
  );
}

(int current, int best) _computeStreaks(List<RecentSubmission> submissions) {
  if (submissions.isEmpty) return (0, 0);

  final daysWithSubmissions = <String>{};
  for (final s in submissions) {
    final d = DateTime(s.submittedAt.year, s.submittedAt.month, s.submittedAt.day);
    daysWithSubmissions.add('${d.year}-${d.month}-${d.day}');
  }

  final now = DateTime.now();
  var currentStreak = 0;
  var day = DateTime(now.year, now.month, now.day);
  while (daysWithSubmissions.contains('${day.year}-${day.month}-${day.day}')) {
    currentStreak++;
    day = day.subtract(const Duration(days: 1));
  }

  var bestStreak = currentStreak;
  var streak = 0;
  final allDays = daysWithSubmissions.toList()..sort();
  for (var i = 0; i < allDays.length; i++) {
    if (i == 0) {
      streak = 1;
    } else {
      final prev = DateTime.parse(allDays[i - 1]);
      final curr = DateTime.parse(allDays[i]);
      if (curr.difference(prev).inDays == 1) {
        streak++;
      } else {
        streak = 1;
      }
    }
    if (streak > bestStreak) bestStreak = streak;
  }

  return (currentStreak, bestStreak);
}

List<int> _computeWeekly(List<RecentSubmission> submissions) {
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

  final counts = List<int>.filled(7, 0);
  for (final s in submissions) {
    if (!s.isCorrect) continue;
    final d = DateTime(s.submittedAt.year, s.submittedAt.month, s.submittedAt.day);
    if (!d.isBefore(start)) {
      final idx = s.submittedAt.weekday - 1;
      if (idx >= 0 && idx < 7) counts[idx]++;
    }
  }
  return counts;
}

List<int> _computeHeatmap(List<RecentSubmission> submissions) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final dayCounts = <String, int>{};
  for (final s in submissions) {
    final d = DateTime(s.submittedAt.year, s.submittedAt.month, s.submittedAt.day);
    final key = '${d.year}-${d.month}-${d.day}';
    dayCounts[key] = (dayCounts[key] ?? 0) + 1;
  }

  final data = List<int>.filled(84, 0);
  for (var i = 0; i < 84; i++) {
    final day = today.subtract(Duration(days: 83 - i));
    final key = '${day.year}-${day.month}-${day.day}';
    final count = dayCounts[key] ?? 0;
    if (count == 0) {
      data[i] = 0;
    } else if (count <= 2) {
      data[i] = 1;
    } else if (count <= 5) {
      data[i] = 2;
    } else {
      data[i] = 3;
    }
  }
  return data;
}

List<PracticeHistoryEntry> _computePracticeHistory(List<RecentSubmission> submissions) {
  final grouped = <int, List<RecentSubmission>>{};
  for (final s in submissions) {
    grouped.putIfAbsent(s.problemId, () => []).add(s);
  }

  final entries = <PracticeHistoryEntry>[];
  for (final entry in grouped.entries) {
    final attempts = entry.value;
    attempts.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    final last = attempts.first;
    entries.add(PracticeHistoryEntry(
      problemId: last.problemId,
      problemName: last.problemName,
      difficulty: last.difficulty,
      lastResult: last.isCorrect,
      lastSubmittedAt: last.submittedAt,
      attempts: attempts,
    ));
  }

  entries.sort((a, b) => b.lastSubmittedAt.compareTo(a.lastSubmittedAt));
  return entries;
}
