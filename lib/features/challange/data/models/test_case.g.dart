// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_case.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TestCase _$TestCaseFromJson(Map<String, dynamic> json) => TestCase(
      input: json['input'] as String?,
      expectedOutput: json['expected_output'] as String?,
    );

Map<String, dynamic> _$TestCaseToJson(TestCase instance) => <String, dynamic>{
      'input': instance.input,
      'expected_output': instance.expectedOutput,
    };

TestCaseResult _$TestCaseResultFromJson(Map<String, dynamic> json) =>
    TestCaseResult(
      input: json['input'] as String?,
      expectedOutput: json['expected_output'] as String?,
      actualOutput: json['actual_output'] as String,
      passed: json['passed'] as bool,
      errorMessage: json['error_message'] as String?,
    );

Map<String, dynamic> _$TestCaseResultToJson(TestCaseResult instance) =>
    <String, dynamic>{
      'input': instance.input,
      'expected_output': instance.expectedOutput,
      'actual_output': instance.actualOutput,
      'passed': instance.passed,
      'error_message': instance.errorMessage,
    };
