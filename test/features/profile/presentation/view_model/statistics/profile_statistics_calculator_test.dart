import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/statistics/profile_statistics_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calculator = ProfileStatisticsCalculator();

  group('ProfileStatisticsCalculator', () {
    group('computeStats()', () {
      test('returns empty statistics for an empty problem list', () {
        final result = calculator.computeStats([], now: _now);

        expect(result.totalProblems, 0);
        expect(result.solvedCount, 0);

        expect(result.easySolved, 0);
        expect(result.mediumSolved, 0);
        expect(result.hardSolved, 0);

        expect(result.easyTotal, 0);
        expect(result.mediumTotal, 0);
        expect(result.hardTotal, 0);

        expect(result.totalAttempts, 0);
        expect(result.correctAttempts, 0);
        expect(result.accuracyRate, 0);

        expect(result.bookmarkedCount, 0);

        expect(result.currentStreak, 0);
        expect(result.bestStreak, 0);

        expect(result.weeklyActivity, List<int>.filled(7, 0));
        expect(result.heatmapData, List<int>.filled(84, 0));

        expect(result.categorySolved, isEmpty);
        expect(result.recentSubmissions, isEmpty);
        expect(result.practiceHistory, isEmpty);
      });

      test('counts total problems', () {
        final problems = [
          _problem(problemId: 1),
          _problem(problemId: 2),
          _problem(problemId: 3),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.totalProblems, 3);
      });

      test('counts problems by difficulty', () {
        final problems = [
          _problem(difficulty: ProblemDifficulty.easy),
          _problem(difficulty: ProblemDifficulty.easy),
          _problem(difficulty: ProblemDifficulty.medium),
          _problem(difficulty: ProblemDifficulty.hard),
          _problem(difficulty: ProblemDifficulty.hard),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.easyTotal, 2);
        expect(result.mediumTotal, 1);
        expect(result.hardTotal, 2);
      });

      test('counts solved problems by difficulty', () {
        final problems = [
          _problem(
            difficulty: ProblemDifficulty.easy,
            problemStatus: ProblemStatus.solved,
          ),
          _problem(
            difficulty: ProblemDifficulty.easy,
            problemStatus: ProblemStatus.attempted,
          ),
          _problem(
            difficulty: ProblemDifficulty.medium,
            problemStatus: ProblemStatus.solved,
          ),
          _problem(
            difficulty: ProblemDifficulty.hard,
            problemStatus: ProblemStatus.solved,
          ),
          _problem(
            difficulty: ProblemDifficulty.hard,
            problemStatus: ProblemStatus.none,
          ),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.solvedCount, 3);

        expect(result.easySolved, 1);
        expect(result.mediumSolved, 1);
        expect(result.hardSolved, 1);
      });

      test('does not count attempted problems as solved', () {
        final problems = [
          _problem(
            difficulty: ProblemDifficulty.easy,
            problemStatus: ProblemStatus.attempted,
          ),
          _problem(
            difficulty: ProblemDifficulty.medium,
            problemStatus: ProblemStatus.none,
          ),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.solvedCount, 0);
        expect(result.easySolved, 0);
        expect(result.mediumSolved, 0);
      });

      test('counts bookmarked problems', () {
        final problems = [
          _problem(isBookmarked: true),
          _problem(isBookmarked: false),
          _problem(isBookmarked: true),
          _problem(isBookmarked: null),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.bookmarkedCount, 2);
      });

      test('counts attempts and correct attempts', () {
        final problems = [
          _problem(
            solutions: [
              _solution(isCorrect: true),
              _solution(isCorrect: false),
              _solution(isCorrect: null),
            ],
          ),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.totalAttempts, 3);
        expect(result.correctAttempts, 1);
      });

      test('accuracyRate is zero when there are no attempts', () {
        final problems = [
          _problem(),
          _problem(),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.accuracyRate, 0);
      });

      test('calculates accuracyRate correctly', () {
        final problems = [
          _problem(
            solutions: [
              _solution(isCorrect: true),
              _solution(isCorrect: true),
              _solution(isCorrect: false),
              _solution(isCorrect: false),
            ],
          ),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.totalAttempts, 4);
        expect(result.correctAttempts, 2);
        expect(result.accuracyRate, 0.5);
      });

      test('does not treat null isCorrect as a correct attempt', () {
        final problems = [
          _problem(
            solutions: [
              _solution(isCorrect: null),
              _solution(isCorrect: false),
            ],
          ),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.totalAttempts, 2);
        expect(result.correctAttempts, 0);
        expect(result.accuracyRate, 0);
      });

      test('counts solved problems by category', () {
        final problems = [
          _problem(category: 'Arrays', problemStatus: ProblemStatus.solved),
          _problem(category: 'Arrays', problemStatus: ProblemStatus.solved),
          _problem(category: 'Arrays', problemStatus: ProblemStatus.attempted),
          _problem(category: 'Strings', problemStatus: ProblemStatus.solved),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.categorySolved, {'Arrays': 2, 'Strings': 1});
      });

      test('does not add an empty category', () {
        final problems = [_problem(category: '', problemStatus: ProblemStatus.solved)];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.categorySolved, isEmpty);
      });

      test('does not add unsolved problems to category statistics', () {
        final problems = [
          _problem(category: 'Arrays', problemStatus: ProblemStatus.attempted),
          _problem(category: 'Strings', problemStatus: ProblemStatus.none),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.categorySolved, isEmpty);
      });

      test('creates a RecentSubmission only when submittedAt exists', () {
        final submittedAt = DateTime(2026, 8, 20);

        final problems = [
          _problem(
            problemId: 10,
            name: 'Two Sum',
            difficulty: ProblemDifficulty.easy,
            solutions: [
              _solution(
                isCorrect: true,
                submittedAt: submittedAt,
              ),
              _solution(
                isCorrect: false,
                submittedAt: null,
              ),
            ],
          ),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.totalAttempts, 2);
        expect(result.recentSubmissions.length, 1);

        final submission = result.recentSubmissions.first;

        expect(submission.problemId, 10);
        expect(submission.problemName, 'Two Sum');
        expect(submission.difficulty, ProblemDifficulty.easy);
        expect(submission.isCorrect, true);
        expect(submission.submittedAt, submittedAt);
      });

      test('sorts recent submissions from newest to oldest', () {
        final older = DateTime(2026, 8, 10);
        final newer = DateTime(2026, 8, 20);

        final problems = [
          _problem(
            problemId: 1,
            name: 'Older',
            solutions: [
              _solution(
                isCorrect: true,
                submittedAt: older,
              ),
            ],
          ),
          _problem(
            problemId: 2,
            name: 'Newer',
            solutions: [
              _solution(
                isCorrect: true,
                submittedAt: newer,
              ),
            ],
          ),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.recentSubmissions.map((submission) => submission.problemId), [2, 1]);
      });

      test('recentSubmissions contains at most 8 submissions', () {
        final problems = List.generate(
          10,
          (index) => _problem(
            problemId: index,
            solutions: [
              _solution(
                isCorrect: index % 2 == 0,
                submittedAt: DateTime(2026, 8, index),
              ),
            ],
          ),
        );

        final result = calculator.computeStats(problems, now: _now);

        expect(result.recentSubmissions.length, 8);
      });

      test('recentSubmissions keeps the 8 newest submissions', () {
        final problems = List.generate(
          10,
          (index) => _problem(
            problemId: index,
            solutions: [
              _solution(
                isCorrect: true,
                submittedAt: DateTime(2026, 8, index),
              ),
            ],
          ),
        );

        final result = calculator.computeStats(problems, now: _now);

        expect(
          result.recentSubmissions.map((submission) => submission.problemId),
          [9, 8, 7, 6, 5, 4, 3, 2],
        );
      });

      test('null isCorrect becomes false in RecentSubmission', () {
        final problems = [
          _problem(
            solutions: [
              _solution(
                isCorrect: null,
                submittedAt: DateTime(2026, 8, 20),
              ),
            ],
          ),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.recentSubmissions.first.isCorrect, false);
      });
    });

    group('practice history', () {
      test('creates one practice history entry per problem', () {
        final submittedAt = DateTime(2026, 8, 20);

        final problems = [
          _problem(
            problemId: 10,
            name: 'Two Sum',
            solutions: [
              _solution(
                isCorrect: true,
                submittedAt: submittedAt,
              ),
            ],
          ),
          _problem(
            problemId: 20,
            name: 'Binary Search',
            solutions: [
              _solution(
                isCorrect: false,
                submittedAt: submittedAt,
              ),
            ],
          ),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.practiceHistory.length, 2);

        expect(result.practiceHistory.map((entry) => entry.problemId), [10, 20]);
      });

      test('groups multiple submissions for the same problem', () {
        final first = DateTime(2026, 8, 10);
        final second = DateTime(2026, 8, 20);

        final problems = [
          _problem(
            problemId: 10,
            name: 'Two Sum',
            solutions: [
              _solution(
                isCorrect: false,
                submittedAt: first,
              ),
              _solution(
                isCorrect: true,
                submittedAt: second,
              ),
            ],
          ),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.practiceHistory.length, 1);
        expect(result.practiceHistory.first.attempts.length, 2);
      });

      test('practice history uses the latest submission as the last result', () {
        final older = DateTime(2026, 8, 10);
        final newer = DateTime(2026, 8, 20);

        final problems = [
          _problem(
            problemId: 10,
            name: 'Two Sum',
            solutions: [
              _solution(
                isCorrect: true,
                submittedAt: older,
              ),
              _solution(
                isCorrect: false,
                submittedAt: newer,
              ),
            ],
          ),
        ];

        final result = calculator.computeStats(problems, now: _now);

        final history = result.practiceHistory.first;

        expect(history.lastResult, false);
        expect(history.lastSubmittedAt, newer);
      });

      test('practice history is sorted by latest submission', () {
        final older = DateTime(2026, 8, 10);
        final newer = DateTime(2026, 8, 20);

        final problems = [
          _problem(
            problemId: 1,
            name: 'Older',
            solutions: [
              _solution(
                isCorrect: true,
                submittedAt: older,
              ),
            ],
          ),
          _problem(
            problemId: 2,
            name: 'Newer',
            solutions: [
              _solution(
                isCorrect: true,
                submittedAt: newer,
              ),
            ],
          ),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.practiceHistory.map((entry) => entry.problemId), [2, 1]);
      });

      test('practice history ignores submissions without submittedAt', () {
        final problems = [
          _problem(
            problemId: 10,
            solutions: [
              _solution(
                isCorrect: true,
                submittedAt: null,
              ),
            ],
          ),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.practiceHistory, isEmpty);
      });
    });

    group('streaks', () {
      test('returns zero streaks when there are no submissions', () {
        final result = calculator.computeStats([], now: _now);

        expect(result.currentStreak, 0);
        expect(result.bestStreak, 0);
      });

      test('counts today as a current streak day', () {
        final today = _today();

        final problems = [
          _problem(
            solutions: [
              _solution(
                submittedAt: today,
                isCorrect: true,
              ),
            ],
          ),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.currentStreak, 1);
        expect(result.bestStreak, 1);
      });

      test('counts consecutive current days as one streak', () {
        final today = _today();

        final problems = [
          _problem(
            problemId: 1,
            solutions: [
              _solution(
                isCorrect: true,
                submittedAt: today,
              ),
            ],
          ),
          _problem(
            problemId: 2,
            solutions: [
              _solution(
                isCorrect: true,
                submittedAt: _daysAgo(1),
              ),
            ],
          ),
          _problem(
            problemId: 3,
            solutions: [
              _solution(
                isCorrect: true,
                submittedAt: _daysAgo(2),
              ),
            ],
          ),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.currentStreak, 3);
        expect(result.bestStreak, 3);
      });

      test('multiple submissions on the same day count as one streak day', () {
        final today = _today();

        final problems = [
          _problem(
            problemId: 1,
            solutions: [
              _solution(
                isCorrect: true,
                submittedAt: today,
              ),
              _solution(
                isCorrect: false,
                submittedAt: today.add(const Duration(hours: 2)),
              ),
            ],
          ),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.currentStreak, 1);
        expect(result.bestStreak, 1);
      });

      test('a run that reached yesterday is still alive today', () {
        final yesterday = _daysAgo(1);

        final problems = [
          _problem(
            solutions: [
              _solution(
                isCorrect: true,
                submittedAt: yesterday,
              ),
            ],
          ),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.currentStreak, 1);
        expect(result.bestStreak, 1);
      });

      test('best streak finds the longest historical streak', () {
        final today = _today();

        final problems = [
// Historical 3-day streak.
          _problem(
            problemId: 1,
            solutions: [
              _solution(
                submittedAt: _daysAgo(10),
                isCorrect: true,
              ),
            ],
          ),
          _problem(
            problemId: 2,
            solutions: [
              _solution(
                submittedAt: _daysAgo(9),
                isCorrect: true,
              ),
            ],
          ),
          _problem(
            problemId: 3,
            solutions: [
              _solution(
                submittedAt: _daysAgo(8),
                isCorrect: true,
              ),
            ],
          ),
// Today only.
          _problem(
            problemId: 4,
            solutions: [
              _solution(
                submittedAt: today,
                isCorrect: true,
              ),
            ],
          ),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.currentStreak, 1);
        expect(result.bestStreak, 3);
      });

      test('a gap breaks a streak', () {
        final today = _today();

        final problems = [
          _problem(
            problemId: 1,
            solutions: [
              _solution(
                submittedAt: today,
                isCorrect: true,
              ),
            ],
          ),
          _problem(
            problemId: 2,
            solutions: [
              _solution(
                submittedAt: _daysAgo(2),
                isCorrect: true,
              ),
            ],
          ),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.currentStreak, 1);
        expect(result.bestStreak, 1);
      });
    });

    group('weekly activity', () {
      test('returns seven days', () {
        final result = calculator.computeStats([], now: _now);

        expect(result.weeklyActivity.length, 7);
      });

      test('counts only correct submissions', () {
        final today = _today();

        final problems = [
          _problem(
            problemId: 1,
            solutions: [
              _solution(
                isCorrect: true,
                submittedAt: today,
              ),
              _solution(
                isCorrect: true,
                submittedAt: today.add(const Duration(hours: 1)),
              ),
              _solution(
                isCorrect: false,
                submittedAt: today.add(const Duration(hours: 2)),
              ),
            ],
          ),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(
          result.weeklyActivity[today.weekday - 1],
          2,
        );
      });

      test('ignores submissions from previous weeks', () {
        final today = _today();
        final previousWeek = _daysAgo(7);

        final problems = [
          _problem(
            solutions: [
              _solution(
                isCorrect: true,
                submittedAt: previousWeek,
              ),
              _solution(
                isCorrect: true,
                submittedAt: today,
              ),
            ],
          ),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.weeklyActivity.reduce((a, b) => a + b), 1);
      });

      test('does not count an incorrect submission in weekly activity', () {
        final today = _today();

        final problems = [
          _problem(
            solutions: [
              _solution(
                isCorrect: false,
                submittedAt: today,
              ),
            ],
          ),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.weeklyActivity, List<int>.filled(7, 0));
      });
    });

    group('heatmap', () {
      test('returns 84 days', () {
        final result = calculator.computeStats([], now: _now);

        expect(result.heatmapData.length, 84);
      });

      test('returns zero for a day with no submissions', () {
        final result = calculator.computeStats([], now: _now);

        expect(
          result.heatmapData.every((count) => count == 0),
          true,
        );
      });

      test('maps 1 or 2 submissions to heatmap level 1', () {
        final today = _today();

        final problems = [
          _problem(
            problemId: 1,
            solutions: [
              _solution(
                isCorrect: true,
                submittedAt: today,
              ),
              _solution(
                isCorrect: false,
                submittedAt: today.add(const Duration(hours: 1)),
              ),
            ],
          ),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.heatmapData.last, 1);
      });

      test('maps 3 to 5 submissions to heatmap level 2', () {
        final today = _today();

        final problems = [
          _problem(
            solutions: List.generate(
              3,
              (_) => _solution(
                isCorrect: true,
                submittedAt: today,
              ),
            ),
          ),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.heatmapData.last, 2);
      });

      test('maps 6 to 9 submissions to heatmap level 3', () {
        final today = _today();

        final problems = [
          _problem(
            solutions: List.generate(
              6,
              (_) => _solution(
                isCorrect: true,
                submittedAt: today,
              ),
            ),
          ),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.heatmapData.last, 3);
      });

      test('maps 10 or more submissions to heatmap level 4', () {
        final today = _today();

        final problems = [
          _problem(
            solutions: List.generate(
              10,
              (_) => _solution(
                isCorrect: true,
                submittedAt: today,
              ),
            ),
          ),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.heatmapData.last, 4);
      });

      test('heatmap counts both correct and incorrect submissions', () {
        final today = _today();

        final problems = [
          _problem(
            solutions: [
              _solution(
                isCorrect: true,
                submittedAt: today,
              ),
              _solution(
                isCorrect: false,
                submittedAt: today,
              ),
              _solution(
                isCorrect: null,
                submittedAt: today,
              ),
            ],
          ),
        ];

        final result = calculator.computeStats(problems, now: _now);

        expect(result.heatmapData.last, 2);
      });
    });
  });

  group('missed days', () {
    test('a whole missed day ends the current streak', () {
      final problems = [
        _problem(solutions: [_solution(isCorrect: true, submittedAt: _daysAgo(2))]),
      ];

      final result = calculator.computeStats(problems, now: _now);

      expect(result.currentStreak, 0);
      expect(result.bestStreak, 1);
    });

    test('the current streak stops at the first missed day', () {
      final problems = [
        _problem(
          solutions: [
            for (final days in [0, 1, 3, 4, 5]) _solution(isCorrect: true, submittedAt: _daysAgo(days)),
          ],
        ),
      ];

      final result = calculator.computeStats(problems, now: _now);

      expect(result.currentStreak, 2);
      expect(result.bestStreak, 3);
    });
  });

  group('dates', () {
    test('a run across the new year keeps counting', () {
      final now = DateTime(2027, 1, 2, 12); // a Saturday
      final problems = [
        _problem(
          solutions: [
            for (final day in [DateTime(2026, 12, 30), DateTime(2026, 12, 31), DateTime(2027, 1, 1), DateTime(2027, 1, 2)])
              _solution(isCorrect: true, submittedAt: day),
          ],
        ),
      ];

      final result = calculator.computeStats(problems, now: now);

      expect(result.currentStreak, 4);
      expect(result.bestStreak, 4);
      expect(result.weeklyActivity, [0, 0, 1, 1, 1, 1, 0]);
      expect(result.heatmapData.sublist(79), [0, 1, 1, 1, 1]);
    });

    // Only a time zone with daylight saving has a 23 or 25 hour day to test.
    final clockChanges = [
      for (var i = 0; i < 365; i++)
        if (DateTime(2026, 1, 2 + i).difference(DateTime(2026, 1, 1 + i)) != const Duration(days: 1))
          DateTime(2026, 1, 1 + i),
    ];

    for (final day in clockChanges) {
      test('a clock change on ${day.month}/${day.day} does not break the streak or shift the heatmap', () {
        final before = DateTime(day.year, day.month, day.day - 1);
        final after = DateTime(day.year, day.month, day.day + 1);
        final problems = [
          _problem(
            solutions: [for (final d in [before, day, after]) _solution(isCorrect: true, submittedAt: d)],
          ),
        ];

        final result = calculator.computeStats(problems, now: DateTime(after.year, after.month, after.day, 12));

        expect(result.currentStreak, 3);
        expect(result.bestStreak, 3);
        expect(result.heatmapData.sublist(80), [0, 1, 1, 1]);
      });
    }

    if (clockChanges.isEmpty) {
      test('a clock change does not break the streak', () {}, skip: 'this time zone has no daylight saving');
    }
  });

  test('1,000 entries over 500 days', () {
    final problems = [
      for (var i = 0; i < 1000; i++)
        _problem(
          problemId: i,
          solutions: [_solution(isCorrect: true, submittedAt: _daysAgo(i ~/ 2))],
        ),
    ];

    final result = calculator.computeStats(problems, now: _now);

    expect(result.totalAttempts, 1000);
    expect(result.currentStreak, 500);
    expect(result.bestStreak, 500);
    expect(result.heatmapData, List.filled(84, 1));
    expect(result.recentSubmissions, hasLength(8));
    expect(result.practiceHistory, hasLength(1000));
  });
}

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

ProblemSolutionStatusDTO _solution({bool? isCorrect = false, DateTime? submittedAt}) {
  return ProblemSolutionStatusDTO(
    code: 'test code',
    isCorrect: isCorrect,
    submittedAt: submittedAt,
  );
}

/// A fixed Wednesday noon, so no test changes result at midnight or on a clock-change day.
final _now = DateTime(2026, 9, 30, 12);

DateTime _today() => DateTime(_now.year, _now.month, _now.day);

DateTime _daysAgo(int days) => DateTime(_now.year, _now.month, _now.day - days);
