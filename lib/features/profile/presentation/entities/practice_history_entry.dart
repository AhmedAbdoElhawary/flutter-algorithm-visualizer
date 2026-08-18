import 'package:algorithm_visualizer/features/challange/domain/enums/problem.dart';

import 'recent_submission.dart';

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
