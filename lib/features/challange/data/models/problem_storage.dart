import 'package:algorithm_visualizer/features/challange/data/models/test_case.dart';
import 'package:algorithm_visualizer/features/challange/domain/enums/problem.dart';
import 'package:json_annotation/json_annotation.dart';

part 'problem_storage.g.dart';

@JsonSerializable()
class ProblemStorageDTO {
  const ProblemStorageDTO({
    required this.problemId,
    required this.problemStatus,
    required this.isBookmarked,
    required this.solutionsStatus,
  });

  final int? problemId;
  final ProblemStatus? problemStatus;
  final bool? isBookmarked;
  final List<ProblemSolutionStatusDTO>? solutionsStatus;

  factory ProblemStorageDTO.fromJson(Map<String, dynamic> json) =>
      _$ProblemStorageDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ProblemStorageDTOToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProblemStorageDTO &&
          runtimeType == other.runtimeType &&
          problemId == other.problemId &&
          problemStatus == other.problemStatus &&
          isBookmarked == other.isBookmarked;

  @override
  int get hashCode => Object.hash(runtimeType, problemId, problemStatus, isBookmarked);
}

@JsonSerializable()
class ProblemSolutionStatusDTO {
  const ProblemSolutionStatusDTO({
    required this.code,
    required this.allTestCaseResults,
    required this.isCorrect,
    this.submittedAt,
  });

  final String? code;
  final List<TestCaseResult>? allTestCaseResults;
  final bool? isCorrect;
  final DateTime? submittedAt;

  factory ProblemSolutionStatusDTO.fromJson(Map<String, dynamic> json) =>
      _$ProblemSolutionStatusDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ProblemSolutionStatusDTOToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProblemSolutionStatusDTO &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          isCorrect == other.isCorrect &&
          submittedAt == other.submittedAt;

  @override
  int get hashCode => Object.hash(runtimeType, code, isCorrect, submittedAt);
}
