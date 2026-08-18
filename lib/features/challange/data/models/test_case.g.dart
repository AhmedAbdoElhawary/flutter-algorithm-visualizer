// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_case.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TestCaseImpl _$$TestCaseImplFromJson(Map<String, dynamic> json) =>
    _$TestCaseImpl(
      input: json['input'] as String?,
      expectedOutput: json['expected_output'] as String?,
    );

Map<String, dynamic> _$$TestCaseImplToJson(_$TestCaseImpl instance) =>
    <String, dynamic>{
      'input': instance.input,
      'expected_output': instance.expectedOutput,
    };

_$SingleTestCaseResultImpl _$$SingleTestCaseResultImplFromJson(
        Map<String, dynamic> json) =>
    _$SingleTestCaseResultImpl(
      input: json['input'] as String?,
      expectedOutput: json['expected_output'] as String?,
      actualOutput: json['actual_output'] as String,
      passed: json['passed'] as bool,
      errorMessage: json['error_message'] as String?,
    );

Map<String, dynamic> _$$SingleTestCaseResultImplToJson(
        _$SingleTestCaseResultImpl instance) =>
    <String, dynamic>{
      'input': instance.input,
      'expected_output': instance.expectedOutput,
      'actual_output': instance.actualOutput,
      'passed': instance.passed,
      'error_message': instance.errorMessage,
    };
