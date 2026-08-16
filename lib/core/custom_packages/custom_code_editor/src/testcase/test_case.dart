/// Models used by the problem runner to execute and grade a coding problem.
library;

class ProblemTestCase {
  const ProblemTestCase({required this.input, required this.expectedOutput});

  final String input;
  final String expectedOutput;
}

class SingleTestCaseResult {
  const SingleTestCaseResult({
    required this.testCase,
    required this.passed,
    required this.actualOutput,
    this.errorMessage,
  });

  final ProblemTestCase testCase;
  final bool passed;
  final String actualOutput;
  final String? errorMessage;
}

class ProblemRunResult {
  const ProblemRunResult({
    required this.testCaseResults,
    required this.allPassed,
    required this.passedCount,
    required this.totalCount,
    this.error,
  });

  final List<SingleTestCaseResult> testCaseResults;
  final bool allPassed;
  final int passedCount;
  final int totalCount;
  final String? error;
}
