import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';

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
