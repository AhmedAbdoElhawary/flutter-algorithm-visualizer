import 'function_signature.dart';
import 'example.dart';
import 'test_case.dart';
import 'hidden_test_case.dart';
import 'solution_approach.dart';
import 'similar_question.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'problem_dto.freezed.dart';
part 'problem_dto.g.dart';

enum ProblemStatus { solved, attempted, todo }

enum ProblemDifficulty { all, easy, medium, hard }

@freezed
class ProblemDTO with _$ProblemDTO {
  const factory ProblemDTO({
    required int problemId,
    required String name,
    required String source,
    int? sourceProblemNumber,
    required String difficulty,
    required String category,
    required List<String> tags,
    required List<String> patterns,
    required String description,
    required List<String> constraints,
    required FunctionSignature functionSignature,
    required List<Example> examples,
    required List<String> edgeCases,
    required List<TestCase> testCases,
    required List<HiddenTestCase> hiddenTestCases,
    required List<String> hints,
    required SolutionApproach solutionApproach,
    required String expectedTimeComplexity,
    required String expectedSpaceComplexity,
    required String whatYouLearn,
    required String keyPattern,
    required List<String> prerequisites,
    required List<String> followUpConcepts,
    required List<String> commonMistakes,
    required List<SimilarQuestion> similarQuestions,
  }) = _ProblemDTO;

  factory ProblemDTO.fromJson(Map<String, dynamic> json) => _$ProblemDTOFromJson(json);
}

extension ProblemStatusX on ProblemDTO {
  // bool get isSolved => status == ProblemStatus.solved;
}

extension ProblemDifficultyX on ProblemDifficulty {
  String get difficultyString => _capitalizeFirstLetter(name);
}

extension ProblemStatusXX on ProblemStatus {
  String get difficultyString => _capitalizeFirstLetter(name);
}

String _capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;

  return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
}
