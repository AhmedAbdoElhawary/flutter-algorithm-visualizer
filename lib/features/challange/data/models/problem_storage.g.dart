// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'problem_storage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProblemStorageDTOImpl _$$ProblemStorageDTOImplFromJson(
        Map<String, dynamic> json) =>
    _$ProblemStorageDTOImpl(
      problemId: (json['problem_id'] as num?)?.toInt(),
      problemStatus:
          $enumDecodeNullable(_$ProblemStatusEnumMap, json['problem_status']),
      isBookmarked: json['is_bookmarked'] as bool?,
      solutionsStatus: (json['solutions_status'] as List<dynamic>?)
          ?.map((e) =>
              ProblemSolutionStatusDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ProblemStorageDTOImplToJson(
        _$ProblemStorageDTOImpl instance) =>
    <String, dynamic>{
      'problem_id': instance.problemId,
      'problem_status': _$ProblemStatusEnumMap[instance.problemStatus],
      'is_bookmarked': instance.isBookmarked,
      'solutions_status': instance.solutionsStatus,
    };

const _$ProblemStatusEnumMap = {
  ProblemStatus.solved: 'solved',
  ProblemStatus.attempted: 'attempted',
  ProblemStatus.none: 'none',
};

_$ProblemSolutionStatusDTOImpl _$$ProblemSolutionStatusDTOImplFromJson(
        Map<String, dynamic> json) =>
    _$ProblemSolutionStatusDTOImpl(
      code: json['code'] as String?,
      failedTestCase: json['failed_test_case'] == null
          ? null
          : TestCase.fromJson(json['failed_test_case'] as Map<String, dynamic>),
      isCorrect: json['is_correct'] as bool?,
    );

Map<String, dynamic> _$$ProblemSolutionStatusDTOImplToJson(
        _$ProblemSolutionStatusDTOImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'failed_test_case': instance.failedTestCase,
      'is_correct': instance.isCorrect,
    };
