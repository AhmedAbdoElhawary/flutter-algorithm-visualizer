import 'package:json_annotation/json_annotation.dart';

part 'test_case.g.dart';

@JsonSerializable()
class TestCase {
  const TestCase({required this.input, required this.expectedOutput});

  final String? input;
  final String? expectedOutput;

  factory TestCase.fromJson(Map<String, dynamic> json) => _$TestCaseFromJson(json);

  Map<String, dynamic> toJson() => _$TestCaseToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestCase &&
          runtimeType == other.runtimeType &&
          input == other.input &&
          expectedOutput == other.expectedOutput;

  @override
  int get hashCode => Object.hash(runtimeType, input, expectedOutput);
}

@JsonSerializable()
class TestCaseResult {
  const TestCaseResult({
    required this.input,
    required this.expectedOutput,
    required this.actualOutput,
    required this.passed,
    this.errorMessage,
  });

  final String? input;
  final String? expectedOutput;
  final String actualOutput;
  final bool passed;
  final String? errorMessage;

  factory TestCaseResult.fromJson(Map<String, dynamic> json) =>
      _$TestCaseResultFromJson(json);

  Map<String, dynamic> toJson() => _$TestCaseResultToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestCaseResult &&
          runtimeType == other.runtimeType &&
          input == other.input &&
          expectedOutput == other.expectedOutput &&
          actualOutput == other.actualOutput &&
          passed == other.passed &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(runtimeType, input, expectedOutput, actualOutput, passed, errorMessage);
}
