// lib/models/dataset.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'problem_dto.dart';

part 'dataset.freezed.dart';
part 'dataset.g.dart';

@freezed
class Dataset with _$Dataset {
  const factory Dataset({
    required String name,
    required String version,
    required int totalProblems,
    required String source,
    required String description,
    required List<ProblemDTO> problems,
  }) = _Dataset;

  factory Dataset.fromJson(Map<String, dynamic> json) => _$DatasetFromJson(json);
}