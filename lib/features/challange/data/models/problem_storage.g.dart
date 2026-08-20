// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'problem_storage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProblemStorageDTO _$ProblemStorageDTOFromJson(Map<String, dynamic> json) =>
    ProblemStorageDTO(
      problemId: (json['problem_id'] as num?)?.toInt(),
      problemStatus:
          $enumDecodeNullable(_$ProblemStatusEnumMap, json['problem_status']),
      isBookmarked: json['is_bookmarked'] as bool?,
      solutionsStatus: (json['solutions_status'] as List<dynamic>?)
          ?.map((e) =>
              ProblemSolutionStatusDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProblemStorageDTOToJson(ProblemStorageDTO instance) =>
    <String, dynamic>{
      'problem_id': instance.problemId,
      'problem_status': _$ProblemStatusEnumMap[instance.problemStatus],
      'is_bookmarked': instance.isBookmarked,
      'solutions_status':
          instance.solutionsStatus?.map((e) => e.toJson()).toList(),
    };

const _$ProblemStatusEnumMap = {
  ProblemStatus.solved: 'solved',
  ProblemStatus.attempted: 'attempted',
  ProblemStatus.none: 'none',
};

ProblemSolutionStatusDTO _$ProblemSolutionStatusDTOFromJson(
        Map<String, dynamic> json) =>
    ProblemSolutionStatusDTO(
      code: json['code'] as String?,
      allTestCaseResults: (json['all_test_case_results'] as List<dynamic>?)
          ?.map((e) => TestCaseResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      isCorrect: json['is_correct'] as bool?,
      submittedAt: json['submitted_at'] == null
          ? null
          : DateTime.parse(json['submitted_at'] as String),
    );

Map<String, dynamic> _$ProblemSolutionStatusDTOToJson(
        ProblemSolutionStatusDTO instance) =>
    <String, dynamic>{
      'code': instance.code,
      'all_test_case_results':
          instance.allTestCaseResults?.map((e) => e.toJson()).toList(),
      'is_correct': instance.isCorrect,
      'submitted_at': instance.submittedAt?.toIso8601String(),
    };
