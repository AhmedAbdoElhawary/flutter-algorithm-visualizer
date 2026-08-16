// import 'package:algorithm_visualizer/features/challange/challange/domain/entities/execution_result.dart';
// import 'package:algorithm_visualizer/features/challange/challange/domain/entities/test_case.dart';
// import 'package:algorithm_visualizer/features/challange/challange/domain/repositories/code_runner_repository.dart';
//
// /// Runs [sourceCode] once and grades it against every entry in [testCases].
// ///
// /// TODO(ahmed): the sample program only prints a single result, so every
// /// test case is currently graded against that same output. Once the editor
// /// supports running the program once per test-case input, replace the
// /// single `_runnerRepository.runCode(sourceCode)` call below with one call
// /// per [CodeTestCase.input].
// class RunCodeUseCase {
//   const RunCodeUseCase(this._runnerRepository);
//
//   final CodeRunnerRepository _runnerRepository;
//
//   Future<ExecutionResult> call({
//     required String sourceCode,
//     required List<CodeTestCase> testCases,
//   }) async {
//     final rawOutput = await _runnerRepository.runCode(sourceCode);
//     final trimmedOutput = rawOutput.trim();
//
//     final results = testCases
//         .map(
//           (testCase) => TestCaseResult(
//             testCase: testCase,
//             actualOutput: trimmedOutput,
//             passed: trimmedOutput == testCase.expectedOutput.trim(),
//           ),
//         )
//         .toList(growable: false);
//
//     return ExecutionResult(testCaseResults: results, consoleOutput: rawOutput);
//   }
// }
