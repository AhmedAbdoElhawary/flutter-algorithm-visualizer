import 'package:algorithm_visualizer/features/challange/data/models/custom_object.dart';
import 'package:algorithm_visualizer/features/challange/data/models/example.dart';
import 'package:algorithm_visualizer/features/challange/data/models/function_signature.dart';
import 'package:algorithm_visualizer/features/challange/data/models/similar_question.dart';
import 'package:algorithm_visualizer/features/challange/data/models/solution_approach.dart';
import 'package:algorithm_visualizer/features/challange/data/models/test_case.dart';
import 'package:algorithm_visualizer/features/challange/domain/enums/problem.dart';
import 'package:json_annotation/json_annotation.dart';

part 'problem_dto.g.dart';

@JsonSerializable()
class ProblemDTO {
  const ProblemDTO({
    required this.problemId,
    required this.number,
    required this.name,
    required this.source,
    this.sourceProblemNumber,
    required this.difficulty,
    required this.category,
    required this.tags,
    required this.patterns,
    required this.description,
    required this.constraints,
    required this.functionSignature,
    this.defaultCode,
    this.customObjects,
    required this.examples,
    required this.edgeCases,
    required this.testCases,
    required this.hiddenTestCases,
    required this.hints,
    required this.solutionApproach,
    required this.expectedTimeComplexity,
    required this.expectedSpaceComplexity,
    required this.whatYouLearn,
    required this.keyPattern,
    required this.prerequisites,
    required this.followUpConcepts,
    required this.commonMistakes,
    required this.similarQuestions,
  });

  final int? problemId;
  final int? number;
  final String? name;
  final String? source;
  final int? sourceProblemNumber;
  final ProblemDifficulty? difficulty;
  final String? category;
  final List<String>? tags;
  final List<String>? patterns;
  final String? description;
  final List<String>? constraints;
  final FunctionSignature? functionSignature;
  final Map<String, String>? defaultCode;
  final Map<String, List<CustomObject>>? customObjects;
  final List<Example>? examples;
  final List<String>? edgeCases;
  final List<TestCase>? testCases;
  final List<TestCase>? hiddenTestCases;
  final List<String>? hints;
  final SolutionApproach? solutionApproach;
  final String? expectedTimeComplexity;
  final String? expectedSpaceComplexity;
  final String? whatYouLearn;
  final String? keyPattern;
  final List<String>? prerequisites;
  final List<String>? followUpConcepts;
  final List<String>? commonMistakes;
  final List<SimilarQuestion>? similarQuestions;

  factory ProblemDTO.fromJson(Map<String, dynamic> json) => _$ProblemDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ProblemDTOToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProblemDTO &&
          runtimeType == other.runtimeType &&
          problemId == other.problemId &&
          number == other.number &&
          name == other.name &&
          source == other.source &&
          sourceProblemNumber == other.sourceProblemNumber &&
          difficulty == other.difficulty &&
          category == other.category;

  @override
  int get hashCode => Object.hash(runtimeType, problemId, number, name, source, difficulty, category);
}
