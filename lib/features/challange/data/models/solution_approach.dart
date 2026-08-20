import 'package:json_annotation/json_annotation.dart';

part 'solution_approach.g.dart';

@JsonSerializable()
class SolutionApproach {
  const SolutionApproach({
    required this.keyObservation,
    required this.algorithm,
    required this.whyItWorks,
    required this.implementationNotes,
  });

  final String? keyObservation;
  final String? algorithm;
  final String? whyItWorks;
  final String? implementationNotes;

  factory SolutionApproach.fromJson(Map<String, dynamic> json) =>
      _$SolutionApproachFromJson(json);

  Map<String, dynamic> toJson() => _$SolutionApproachToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SolutionApproach &&
          runtimeType == other.runtimeType &&
          keyObservation == other.keyObservation &&
          algorithm == other.algorithm &&
          whyItWorks == other.whyItWorks &&
          implementationNotes == other.implementationNotes;

  @override
  int get hashCode => Object.hash(runtimeType, keyObservation, algorithm, whyItWorks, implementationNotes);
}
