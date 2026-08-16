import 'package:freezed_annotation/freezed_annotation.dart';

part 'test_case.freezed.dart';
part 'test_case.g.dart';

@freezed
class TestCase with _$TestCase {
  const factory TestCase({
    required String? input,
    required String? expectedOutput,
  }) = _TestCase;
  // convert from single to this:
  // factory TestCase.fromSingle(SingleTestCaseResult result) => TestCase(
  //       input: result.input,
  //       expectedOutput: result.expectedOutput,
  //     );
  factory TestCase.fromJson(Map<String, dynamic> json) => _$TestCaseFromJson(json);
}

/// Result of grading the user's code against a single test case.
@freezed
class TestCaseResult with _$TestCaseResult {
  const factory TestCaseResult({
    /// The raw `input` string straight from the JSON, e.g. `nums=[2,7,11,15], target=9`.

    required String? input,
    required String? expectedOutput,
    required String actualOutput,
    required bool passed,

    /// Set when this single run failed to parse/execute (not when the output
    /// simply didn't match). Null on a clean run.
    String? errorMessage,
  }) = _SingleTestCaseResult;

  factory TestCaseResult.fromJson(Map<String, dynamic> json) => _$TestCaseResultFromJson(json);
}
