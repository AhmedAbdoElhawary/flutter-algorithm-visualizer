// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dataset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dataset _$DatasetFromJson(Map<String, dynamic> json) => Dataset(
      name: json['name'] as String?,
      version: json['version'] as String?,
      totalProblems: (json['total_problems'] as num?)?.toInt(),
      source: json['source'] as String?,
      description: json['description'] as String?,
      problems: (json['problems'] as List<dynamic>?)
          ?.map((e) => ProblemDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DatasetToJson(Dataset instance) => <String, dynamic>{
      'name': instance.name,
      'version': instance.version,
      'total_problems': instance.totalProblems,
      'source': instance.source,
      'description': instance.description,
      'problems': instance.problems?.map((e) => e.toJson()).toList(),
    };
