//
// /// Outcome of grading a single [CodeTestCase] against the program's output.
// class TestCaseResult {
//   const TestCaseResult({
//     // required this.testCase,
//     required this.actualOutput,
//     required this.passed,
//   });
//
//   // final CodeTestCase testCase;
//   final String actualOutput;
//   final bool passed;
// }
//
// /// Aggregate result of running the user's code against every test case.
// class ExecutionResult {
//   const ExecutionResult({
//     required this.testCaseResults,
//     required this.consoleOutput,
//   });
//
//   final List<TestCaseResult> testCaseResults;
//   final String consoleOutput;
//
//   bool get allPassed => testCaseResults.every((r) => r.passed);
//   int get passedCount => testCaseResults.where((r) => r.passed).length;
// }
