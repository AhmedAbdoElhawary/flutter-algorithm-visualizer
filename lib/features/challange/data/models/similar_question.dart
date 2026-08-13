// lib/models/similar_question.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'similar_question.freezed.dart';
part 'similar_question.g.dart';

@freezed
class SimilarQuestion with _$SimilarQuestion {
  const factory SimilarQuestion({
    required int problemId,
    required String name,
    required String reason,
  }) = _SimilarQuestion;

  factory SimilarQuestion.fromJson(Map<String, dynamic> json) => _$SimilarQuestionFromJson(json);
}
