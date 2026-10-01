import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/profile/domain/entities/practice_history_entry.dart';
import 'package:algorithm_visualizer/features/profile/domain/entities/recent_submission.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  RecentSubmission attempt(bool isCorrect) => RecentSubmission(
    problemId: 1,
    problemName: 'Two Sum',
    difficulty: ProblemDifficulty.easy,
    isCorrect: isCorrect,
    submittedAt: DateTime(2026, 9, 1),
  );

  PracticeHistoryEntry entry(List<bool> results) => PracticeHistoryEntry(
    problemId: 1,
    problemName: 'Two Sum',
    difficulty: ProblemDifficulty.easy,
    lastResult: results.first,
    lastSubmittedAt: DateTime(2026, 9, 1),
    attempts: results.map(attempt).toList(),
  );

  group('isSolved', () {
    test('every attempt passed', () => expect(entry([true, true]).isSolved, isTrue));

    test('passed once after failing', () => expect(entry([true, false, false]).isSolved, isTrue));

    test(
      'failed after passing once still counts as solved',
      () => expect(entry([false, true]).isSolved, isTrue),
    );

    test('never passed', () => expect(entry([false, false]).isSolved, isFalse));
  });
}
