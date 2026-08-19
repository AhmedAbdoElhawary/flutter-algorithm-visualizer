import 'package:algorithm_visualizer/features/challenge/data/models/problem_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dataset.g.dart';

@JsonSerializable()
class Dataset {
  const Dataset({
    required this.name,
    required this.version,
    required this.totalProblems,
    required this.source,
    required this.description,
    required this.problems,
  });

  final String? name;
  final String? version;
  final int? totalProblems;
  final String? source;
  final String? description;
  final List<ProblemDTO>? problems;

  factory Dataset.fromJson(Map<String, dynamic> json) => _$DatasetFromJson(json);

  Map<String, dynamic> toJson() => _$DatasetToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Dataset &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          version == other.version &&
          totalProblems == other.totalProblems &&
          source == other.source &&
          description == other.description;

  @override
  int get hashCode => Object.hash(runtimeType, name, version, totalProblems, source, description);
}
