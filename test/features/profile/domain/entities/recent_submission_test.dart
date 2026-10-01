import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/profile/domain/entities/recent_submission.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps what it was given', () {
    final at = DateTime(2026, 9, 1, 14, 5);
    final submission = RecentSubmission(
      problemId: 7,
      problemName: 'Two Sum',
      difficulty: ProblemDifficulty.hard,
      isCorrect: true,
      submittedAt: at,
    );

    expect(submission.problemId, 7);
    expect(submission.problemName, 'Two Sum');
    expect(submission.difficulty, ProblemDifficulty.hard);
    expect(submission.isCorrect, isTrue);
    expect(submission.submittedAt, at);
  });
}
