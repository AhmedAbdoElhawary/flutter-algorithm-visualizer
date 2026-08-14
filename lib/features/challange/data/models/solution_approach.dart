import 'package:freezed_annotation/freezed_annotation.dart';

part 'solution_approach.freezed.dart';
part 'solution_approach.g.dart';

@freezed
class SolutionApproach with _$SolutionApproach {
  const factory SolutionApproach({
    required String? keyObservation,
    required String? algorithm,
    required String? whyItWorks,
    required String? implementationNotes,
  }) = _SolutionApproach;

  factory SolutionApproach.fromJson(Map<String, dynamic> json) => _$SolutionApproachFromJson(json);
}
