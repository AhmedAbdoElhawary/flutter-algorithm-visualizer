// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'similar_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SimilarQuestion _$SimilarQuestionFromJson(Map<String, dynamic> json) =>
    SimilarQuestion(
      problemId: (json['problem_id'] as num?)?.toInt(),
      name: json['name'] as String?,
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$SimilarQuestionToJson(SimilarQuestion instance) =>
    <String, dynamic>{
      'problem_id': instance.problemId,
      'name': instance.name,
      'reason': instance.reason,
    };
