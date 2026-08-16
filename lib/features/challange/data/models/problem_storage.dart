import 'package:algorithm_visualizer/features/challange/data/models/test_case.dart';
import 'package:algorithm_visualizer/features/challange/domain/enums/problem.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'problem_storage.freezed.dart';
part 'problem_storage.g.dart';

/// [ProblemStorageDTO] it saved in local storage
@freezed
@JsonSerializable(explicitToJson: true)
class ProblemStorageDTO with _$ProblemStorageDTO {
  const factory ProblemStorageDTO({
    required int? problemId,
    required ProblemStatus? problemStatus,
    required bool? isBookmarked,
    required List<ProblemSolutionStatusDTO>? solutionsStatus,
  }) = _ProblemStorageDTO;

  factory ProblemStorageDTO.fromJson(Map<String, dynamic> json) => _$ProblemStorageDTOFromJson(json);
}

@freezed
class ProblemSolutionStatusDTO with _$ProblemSolutionStatusDTO {
  const factory ProblemSolutionStatusDTO({
    required String? code,
    required List<TestCaseResult>? allTestCaseResults,
    required bool? isCorrect,
  }) = _ProblemSolutionStatusDTO;

  factory ProblemSolutionStatusDTO.fromJson(Map<String, dynamic> json) =>
      _$ProblemSolutionStatusDTOFromJson(json);
}
