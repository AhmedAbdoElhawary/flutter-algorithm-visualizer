// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'similar_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SimilarQuestionImpl _$$SimilarQuestionImplFromJson(
        Map<String, dynamic> json) =>
    _$SimilarQuestionImpl(
      problemId: (json['problem_id'] as num).toInt(),
      name: json['name'] as String,
      reason: json['reason'] as String,
    );

Map<String, dynamic> _$$SimilarQuestionImplToJson(
        _$SimilarQuestionImpl instance) =>
    <String, dynamic>{
      'problem_id': instance.problemId,
      'name': instance.name,
      'reason': instance.reason,
    };
