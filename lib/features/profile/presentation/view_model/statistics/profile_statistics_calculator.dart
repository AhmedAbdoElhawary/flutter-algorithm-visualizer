part of 'profile_statistics_provider.dart';

class ProfileStatisticsCalculator {
  const ProfileStatisticsCalculator();

  ProfileStatistics computeStats(List<CodingProblem> problems) {
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

        if (solution.isCorrect == true) {
          correctAttempts++;
        }

        if (solution.submittedAt != null) {
          submissions.add(
            RecentSubmission(
              problemId: problem.getProblemId,
              problemName: problem.getName,
              difficulty: diff,
              isCorrect: solution.isCorrect ?? false,
              submittedAt: solution.submittedAt!,
            ),
          );
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

    return ProfileStatistics(
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
      final d = DateTime(
        s.submittedAt.year,
        s.submittedAt.month,
        s.submittedAt.day,
      );

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

    final allDays = daysWithSubmissions.toList()..sort((a, b) => _parseDate(a).compareTo(_parseDate(b)));

    for (var i = 0; i < allDays.length; i++) {
      if (i == 0) {
        streak = 1;
      } else {
        final prev = _parseDate(allDays[i - 1]);
        final curr = _parseDate(allDays[i]);

        if (curr.difference(prev).inDays == 1) {
          streak++;
        } else {
          streak = 1;
        }
      }

      if (streak > bestStreak) {
        bestStreak = streak;
      }
    }

    return (currentStreak, bestStreak);
  }

  DateTime _parseDate(String s) {
    final parts = s.split('-');

    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  List<int> _computeWeekly(List<RecentSubmission> submissions) {
    final now = DateTime.now();

    final startOfWeek = now.subtract(
      Duration(days: now.weekday - 1),
    );

    final start = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );

    final counts = List<int>.filled(7, 0);

    for (final s in submissions) {
      if (!s.isCorrect) continue;

      final d = DateTime(
        s.submittedAt.year,
        s.submittedAt.month,
        s.submittedAt.day,
      );

      if (!d.isBefore(start)) {
        final idx = s.submittedAt.weekday - 1;

        if (idx >= 0 && idx < 7) {
          counts[idx]++;
        }
      }
    }

    return counts;
  }

  List<int> _computeHeatmap(List<RecentSubmission> submissions) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final dayCounts = <String, int>{};

    for (final s in submissions) {
      final d = DateTime(
        s.submittedAt.year,
        s.submittedAt.month,
        s.submittedAt.day,
      );

      final key = '${d.year}-${d.month}-${d.day}';

      dayCounts[key] = (dayCounts[key] ?? 0) + 1;
    }

    final data = List<int>.filled(84, 0);

    for (var i = 0; i < 84; i++) {
      final day = today.subtract(
        Duration(days: 83 - i),
      );

      final key = '${day.year}-${day.month}-${day.day}';
      final count = dayCounts[key] ?? 0;

      if (count == 0) {
        data[i] = 0;
      } else if (count <= 2) {
        data[i] = 1;
      } else if (count <= 5) {
        data[i] = 2;
      } else if (count <= 9) {
        data[i] = 3;
      } else {
        data[i] = 4;
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

      attempts.sort(
        (a, b) => b.submittedAt.compareTo(a.submittedAt),
      );

      final last = attempts.first;

      entries.add(
        PracticeHistoryEntry(
          problemId: last.problemId,
          problemName: last.problemName,
          difficulty: last.difficulty,
          lastResult: last.isCorrect,
          lastSubmittedAt: last.submittedAt,
          attempts: attempts,
        ),
      );
    }

    entries.sort(
      (a, b) => b.lastSubmittedAt.compareTo(a.lastSubmittedAt),
    );

    return entries;
  }
}

/*
part of 'profile_statistics_provider.dart';

class ProfileStatisticsCalculator {
  const ProfileStatisticsCalculator();

  CodingProblem _problem({
    int? problemId = 1,
    String? name = 'Test Problem',
    ProblemDifficulty? difficulty = ProblemDifficulty.easy,
    String? category = 'Arrays',
    ProblemStatus? problemStatus = ProblemStatus.none,
    bool? isBookmarked = false,
    List<ProblemSolutionStatusDTO>? solutions,
  }) {
    return CodingProblem(
      number: problemId,
      problemId: problemId,
      name: name,
      source: 'Test',
      sourceProblemNumber: problemId,
      difficulty: difficulty,
      category: category,
      tags: const [],
      patterns: const [],
      description: 'Test problem',
      constraints: const [],
      functionSignature: null,
      defaultCode: null,
      customObjects: null,
      examples: const [],
      edgeCases: const [],
      testCases: const [],
      hiddenTestCases: const [],
      hints: const [],
      solutionApproach: null,
      expectedTimeComplexity: 'O(n)',
      expectedSpaceComplexity: 'O(1)',
      whatYouLearn: '',
      keyPattern: '',
      prerequisites: const [],
      followUpConcepts: const [],
      commonMistakes: const [],
      similarQuestions: const [],
      problemStatus: problemStatus,
      isBookmarked: isBookmarked,
      solutionsStatus: solutions ?? const [],
    );
  }

  ProfileStatistics computeStats(List<CodingProblem> p) {
    final problems = [
      ...List.generate(
        20,
        (index) => _problem(
          difficulty: ProblemDifficulty.easy,
          problemStatus: ProblemStatus.solved,          solutions: [ProblemSolutionStatusDTO(code: "code", isCorrect: true),ProblemSolutionStatusDTO(code: "code", isCorrect: false),ProblemSolutionStatusDTO(code: "code", isCorrect: false),]

        ),
      ),
      ...List.generate(
        5,
        (index) => _problem(
          difficulty: ProblemDifficulty.easy,
          problemStatus: ProblemStatus.attempted,
        ),
      ),
      ...List.generate(
        15,
        (index) => _problem(
          difficulty: ProblemDifficulty.medium,
          problemStatus: ProblemStatus.solved,
        ),
      ),
      ...List.generate(
        4,
        (index) => _problem(
          difficulty: ProblemDifficulty.medium,
          problemStatus: ProblemStatus.attempted,
        ),
      ),
      ...List.generate(
        10,
        (index) => _problem(
          difficulty: ProblemDifficulty.hard,
          problemStatus: ProblemStatus.solved,
        ),
      ),
      ...List.generate(
        5,
        (index) => _problem(
          difficulty: ProblemDifficulty.hard,
          problemStatus: ProblemStatus.attempted,
        ),
      ),
      ...List.generate(41, (index) => _problem()),
    ];

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

        if (solution.isCorrect == true) {
          correctAttempts++;
        }

        if (solution.submittedAt != null) {
          submissions.add(
            RecentSubmission(
              problemId: problem.getProblemId,
              problemName: problem.getName,
              difficulty: diff,
              isCorrect: solution.isCorrect ?? false,
              submittedAt: solution.submittedAt!,
            ),
          );
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

    return ProfileStatistics(
      totalProblems: problems.length,
      solvedCount: solvedCount,
      easySolved: easySolved,
      mediumSolved: mediumSolved,
      hardSolved: hardSolved,
      easyTotal: easyTotal,
      mediumTotal: mediumTotal,
      hardTotal: hardTotal,
      totalAttempts: 59,
      correctAttempts: correctAttempts,
      accuracyRate: .88,
      bookmarkedCount: 8,
      currentStreak: 21,
      bestStreak: 34,
      weeklyActivity: [1,4,3,6,2,4,0],
      heatmapData: [...List.generate(84-7, (index) => 0,),1,4,3,6,2,4,2],
      categorySolved: categorySolved,
      recentSubmissions: recent,
      practiceHistory: practiceHistory,
    );
  }

  (int current, int best) _computeStreaks(List<RecentSubmission> submissions) {
    if (submissions.isEmpty) return (0, 0);

    final daysWithSubmissions = <String>{};

    for (final s in submissions) {
      final d = DateTime(
        s.submittedAt.year,
        s.submittedAt.month,
        s.submittedAt.day,
      );

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

    final allDays = daysWithSubmissions.toList()..sort((a, b) => _parseDate(a).compareTo(_parseDate(b)));

    for (var i = 0; i < allDays.length; i++) {
      if (i == 0) {
        streak = 1;
      } else {
        final prev = _parseDate(allDays[i - 1]);
        final curr = _parseDate(allDays[i]);

        if (curr.difference(prev).inDays == 1) {
          streak++;
        } else {
          streak = 1;
        }
      }

      if (streak > bestStreak) {
        bestStreak = streak;
      }
    }

    return (currentStreak, bestStreak);
  }

  DateTime _parseDate(String s) {
    final parts = s.split('-');

    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  List<int> _computeWeekly(List<RecentSubmission> submissions) {
    final now = DateTime.now();

    final startOfWeek = now.subtract(
      Duration(days: now.weekday - 1),
    );

    final start = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );

    final counts = List<int>.filled(7, 0);

    for (final s in submissions) {
      if (!s.isCorrect) continue;

      final d = DateTime(
        s.submittedAt.year,
        s.submittedAt.month,
        s.submittedAt.day,
      );

      if (!d.isBefore(start)) {
        final idx = s.submittedAt.weekday - 1;

        if (idx >= 0 && idx < 7) {
          counts[idx]++;
        }
      }
    }

    return counts;
  }

  List<int> _computeHeatmap(List<RecentSubmission> submissions) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final dayCounts = <String, int>{};

    for (final s in submissions) {
      final d = DateTime(
        s.submittedAt.year,
        s.submittedAt.month,
        s.submittedAt.day,
      );

      final key = '${d.year}-${d.month}-${d.day}';

      dayCounts[key] = (dayCounts[key] ?? 0) + 1;
    }

    final data = List<int>.filled(84, 0);

    for (var i = 0; i < 84; i++) {
      final day = today.subtract(
        Duration(days: 83 - i),
      );

      final key = '${day.year}-${day.month}-${day.day}';
      final count = dayCounts[key] ?? 0;

      if (count == 0) {
        data[i] = 0;
      } else if (count <= 2) {
        data[i] = 1;
      } else if (count <= 5) {
        data[i] = 2;
      } else if (count <= 9) {
        data[i] = 3;
      } else {
        data[i] = 4;
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

      attempts.sort(
        (a, b) => b.submittedAt.compareTo(a.submittedAt),
      );

      final last = attempts.first;

      entries.add(
        PracticeHistoryEntry(
          problemId: last.problemId,
          problemName: last.problemName,
          difficulty: last.difficulty,
          lastResult: last.isCorrect,
          lastSubmittedAt: last.submittedAt,
          attempts: attempts,
        ),
      );
    }

    entries.sort(
      (a, b) => b.lastSubmittedAt.compareTo(a.lastSubmittedAt),
    );

    return entries;
  }
}


* */
