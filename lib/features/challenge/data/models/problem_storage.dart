import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
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

  factory ProblemStorageDTO.fromJson(Map<String, dynamic> json) => _$ProblemStorageDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ProblemStorageDTOToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProblemStorageDTO &&
          problemId == other.problemId &&
          problemStatus == other.problemStatus &&
          isBookmarked == other.isBookmarked;

  @override
  int get hashCode {
    return Object.hash(problemId, problemStatus?.name, isBookmarked, solutionsStatus);
  }
}

@JsonSerializable()
class ProblemSolutionStatusDTO {
  const ProblemSolutionStatusDTO({
    required this.code,
    required this.isCorrect,
    this.submittedAt,
    this.language,
  });

  final String? code;
  final bool? isCorrect;
  final DateTime? submittedAt;

  /// Which language this solution was written in, as a dataset key
  /// (`dart`, `python`, `javascript`).
  ///
  /// Purely additive: a solution saved before the editor offered a choice has
  /// no language, and **null reads as `dart`** (see [languageKey]). No stored
  /// solution is rewritten, moved, or lost by this field appearing.
  final String? language;

  /// The language this solution belongs to, defaulting older saves to Dart.
  String get languageKey => language ?? 'dart';

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
          submittedAt == other.submittedAt &&
          languageKey == other.languageKey;

  @override
  int get hashCode => Object.hash(runtimeType, code, isCorrect, submittedAt, languageKey);
}
