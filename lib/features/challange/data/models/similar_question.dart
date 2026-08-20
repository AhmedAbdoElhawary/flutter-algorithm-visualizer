import 'package:json_annotation/json_annotation.dart';

part 'similar_question.g.dart';

@JsonSerializable()
class SimilarQuestion {
  const SimilarQuestion({required this.problemId, required this.name, required this.reason});

  final int? problemId;
  final String? name;
  final String? reason;

  factory SimilarQuestion.fromJson(Map<String, dynamic> json) =>
      _$SimilarQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$SimilarQuestionToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimilarQuestion &&
          runtimeType == other.runtimeType &&
          problemId == other.problemId &&
          name == other.name &&
          reason == other.reason;

  @override
  int get hashCode => Object.hash(runtimeType, problemId, name, reason);
}
