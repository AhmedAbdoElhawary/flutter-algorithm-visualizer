/// Models used by the problem runner to execute and grade a coding problem.
library;

class ProblemTestCase {
  const ProblemTestCase({required this.input, required this.expectedOutput});

  final String input;
  final String expectedOutput;
}

/// A failure on its way out of the engine, still in pieces.
///
/// This is the `code` + `data` pair the execution contract promises
/// (`contracts/execution-contract.md`, FR-014/FR-015), carried far enough for
/// the widget that shows it to build the sentence — in whatever language the
/// app is currently in. The runner used to render that sentence itself, which
/// worked only because there was one language.
class ExecutionFailureInfo {
  const ExecutionFailureInfo({
    required this.kind,
    required this.code,
    required this.data,
    required this.line,
  });

  /// `FailureKind.name` — `syntax`, `runtime`, `timeLimit`, ...
  final String kind;

  /// Stable identifier such as `indexOutOfRange`. Never English prose.
  final String code;

  /// The values involved, e.g. `{index: 5, length: 3}`.
  final Map<String, Object?> data;

  /// 1-indexed, already rebased onto the learner's own source.
  final int line;
}

class SingleTestCaseResult {
  const SingleTestCaseResult({
    required this.testCase,
    required this.passed,
    required this.actualOutput,
    this.errorMessage,
    this.failure,
  });

  final ProblemTestCase testCase;
  final bool passed;
  final String actualOutput;

  /// The English rendering, kept for logs and for the grading tests that
  /// print it. The UI reads [failure] instead, so it can translate.
  final String? errorMessage;

  final ExecutionFailureInfo? failure;
}

class ProblemRunResult {
  const ProblemRunResult({
    required this.testCaseResults,
    required this.allPassed,
    required this.passedCount,
    required this.totalCount,
    this.error,
    this.failure,
  });

  final List<SingleTestCaseResult> testCaseResults;
  final bool allPassed;
  final int passedCount;
  final int totalCount;

  /// English rendering of [failure], or a message with no structured form
  /// behind it (a malformed signature, say). Tests assert this is null on a
  /// clean run, so it stays.
  final String? error;

  /// The first whole-program failure, in pieces, for the UI to localise.
  /// Null when [error] came from somewhere with no `code` to carry.
  final ExecutionFailureInfo? failure;
}
