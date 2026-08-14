import 'package:algorithm_visualizer/features/challange/domain/enums/problem.dart';

import 'example.dart';
import 'test_case.dart';
import 'solution_approach.dart';
import 'similar_question.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'problem_dto.freezed.dart';
part 'problem_dto.g.dart';

@freezed
class ProblemDTO with _$ProblemDTO {
  const factory ProblemDTO({
    required int? problemId,
    required int? number,
    required String? name,
    required String? source,
    int? sourceProblemNumber,
    required ProblemDifficulty? difficulty,
    required String? category,
    required List<String>? tags,
    required List<String>? patterns,
    required String? description,
    required List<String>? constraints,
    required List<Example>? examples,
    required List<String>? edgeCases,
    required List<TestCase>? testCases,
    required List<TestCase>? hiddenTestCases,
    required List<String>? hints,
    required SolutionApproach? solutionApproach,
    required String? expectedTimeComplexity,
    required String? expectedSpaceComplexity,
    required String? whatYouLearn,
    required String? keyPattern,
    required List<String>? prerequisites,
    required List<String>? followUpConcepts,
    required List<String>? commonMistakes,
    required List<SimilarQuestion>? similarQuestions,
  }) = _ProblemDTO;

  factory ProblemDTO.fromJson(Map<String, dynamic> json) => _$ProblemDTOFromJson(json);
}