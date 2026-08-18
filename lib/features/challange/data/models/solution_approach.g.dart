// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'solution_approach.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SolutionApproach _$SolutionApproachFromJson(Map<String, dynamic> json) =>
    SolutionApproach(
      keyObservation: json['key_observation'] as String?,
      algorithm: json['algorithm'] as String?,
      whyItWorks: json['why_it_works'] as String?,
      implementationNotes: json['implementation_notes'] as String?,
    );

Map<String, dynamic> _$SolutionApproachToJson(SolutionApproach instance) =>
    <String, dynamic>{
      'key_observation': instance.keyObservation,
      'algorithm': instance.algorithm,
      'why_it_works': instance.whyItWorks,
      'implementation_notes': instance.implementationNotes,
    };
