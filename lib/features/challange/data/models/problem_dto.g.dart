// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'problem_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProblemDTOImpl _$$ProblemDTOImplFromJson(Map<String, dynamic> json) =>
    _$ProblemDTOImpl(
      problemId: (json['problem_id'] as num).toInt(),
      name: json['name'] as String,
      source: json['source'] as String,
      sourceProblemNumber: (json['source_problem_number'] as num?)?.toInt(),
      difficulty: json['difficulty'] as String,
      category: json['category'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      patterns:
          (json['patterns'] as List<dynamic>).map((e) => e as String).toList(),
      description: json['description'] as String,
      constraints: (json['constraints'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      functionSignature: FunctionSignature.fromJson(
          json['function_signature'] as Map<String, dynamic>),
      examples: (json['examples'] as List<dynamic>)
          .map((e) => Example.fromJson(e as Map<String, dynamic>))
          .toList(),
      edgeCases: (json['edge_cases'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      testCases: (json['test_cases'] as List<dynamic>)
          .map((e) => TestCase.fromJson(e as Map<String, dynamic>))
          .toList(),
      hiddenTestCases: (json['hidden_test_cases'] as List<dynamic>)
          .map((e) => HiddenTestCase.fromJson(e as Map<String, dynamic>))
          .toList(),
      hints: (json['hints'] as List<dynamic>).map((e) => e as String).toList(),
      solutionApproach: SolutionApproach.fromJson(
          json['solution_approach'] as Map<String, dynamic>),
      expectedTimeComplexity: json['expected_time_complexity'] as String,
      expectedSpaceComplexity: json['expected_space_complexity'] as String,
      whatYouLearn: json['what_you_learn'] as String,
      keyPattern: json['key_pattern'] as String,
      prerequisites: (json['prerequisites'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      followUpConcepts: (json['follow_up_concepts'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      commonMistakes: (json['common_mistakes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      similarQuestions: (json['similar_questions'] as List<dynamic>)
          .map((e) => SimilarQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ProblemDTOImplToJson(_$ProblemDTOImpl instance) =>
    <String, dynamic>{
      'problem_id': instance.problemId,
      'name': instance.name,
      'source': instance.source,
      'source_problem_number': instance.sourceProblemNumber,
      'difficulty': instance.difficulty,
      'category': instance.category,
      'tags': instance.tags,
      'patterns': instance.patterns,
      'description': instance.description,
      'constraints': instance.constraints,
      'function_signature': instance.functionSignature,
      'examples': instance.examples,
      'edge_cases': instance.edgeCases,
      'test_cases': instance.testCases,
      'hidden_test_cases': instance.hiddenTestCases,
      'hints': instance.hints,
      'solution_approach': instance.solutionApproach,
      'expected_time_complexity': instance.expectedTimeComplexity,
      'expected_space_complexity': instance.expectedSpaceComplexity,
      'what_you_learn': instance.whatYouLearn,
      'key_pattern': instance.keyPattern,
      'prerequisites': instance.prerequisites,
      'follow_up_concepts': instance.followUpConcepts,
      'common_mistakes': instance.commonMistakes,
      'similar_questions': instance.similarQuestions,
    };
