import 'package:algorithm_visualizer/core/extensions/string.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challange/data/models/custom_object.dart';
import 'package:algorithm_visualizer/features/challange/data/models/example.dart';
import 'package:algorithm_visualizer/features/challange/data/models/function_signature.dart';
import 'package:algorithm_visualizer/features/challange/data/models/problem_storage.dart';
import 'package:algorithm_visualizer/features/challange/data/models/similar_question.dart';
import 'package:algorithm_visualizer/features/challange/data/models/solution_approach.dart';
import 'package:algorithm_visualizer/features/challange/data/models/test_case.dart';
import 'package:algorithm_visualizer/features/challange/domain/enums/problem.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'coding_problem.freezed.dart';
part 'coding_problem.g.dart';

/// todo: remove what you don't use them

@freezed
class CodingProblem with _$CodingProblem {
  const factory CodingProblem({
    required int? number,
    required int? problemId,
    required String? name,
    required String? source,
    int? sourceProblemNumber,
    required ProblemDifficulty? difficulty,
    required String? category,
    required List<String>? tags,
    required List<String>? patterns,
    required String? description,
    required List<String>? constraints,
    required FunctionSignature? functionSignature,
    Map<String, String>? defaultCode,
    Map<String, List<CustomObject>>? customObjects,
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
    // storage
    required ProblemStatus? problemStatus,
    required bool? isBookmarked,
    required List<ProblemSolutionStatusDTO>? solutionsStatus,
  }) = _CodingProblem;

  factory CodingProblem.fromJson(Map<String, dynamic> json) => _$CodingProblemFromJson(json);
}

extension CodingProblemX on CodingProblem {
  int get getNumber => number ?? -1;
  int get getProblemId => problemId ?? -1;
  String get getName => name ?? '';

  String get getNameWithLanguageName {
    final snakeCase = getName.toSnakeCase
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();

    final parts = snakeCase.split('_');

    while (parts.join('_').length >= 20 && parts.length > 1) {
      parts.removeLast();
    }

    return "${parts.join('_')}.${StringsManager.dart.toLowerCase()}";
  }
  String get getSource => source ?? '';

  int get getSourceProblemNumber => sourceProblemNumber ?? -1;
  ProblemDifficulty get getDifficulty => difficulty ?? ProblemDifficulty.none;
  String get getCategory => category ?? '';
  List<String> get getTags => tags ?? [];
  List<String> get getPatterns => patterns ?? [];
  String get getDescription => description ?? '';
  List<String> get getConstraints => constraints ?? [];

  String get getFunctionInDart {
    final sign = functionSignature?.dart;
    if (sign == null) return "";

    return "$sign{\n\n}";
  }

  /// The problem's starter code (the `dart` entry of `default_code`), or a
  /// bare function stub when the JSON doesn't provide one.
  String get getDefaultCode {
    final code = defaultCode?['dart'];
    if (code == null || code.trim().isEmpty) return getFunctionInDart;
    return code;
  }

  List<CustomObject> get getCustomObjects => customObjects?['dart'] ?? [];

  List<Example> get getExamples => examples ?? [];
  List<String> get getEdgeCases => edgeCases ?? [];
  List<TestCase> get getTestCases => testCases ?? [];
  List<TestCase> get getHiddenTestCases => hiddenTestCases ?? [];
  List<String> get getHints => hints ?? [];
  SolutionApproach? get getSolutionApproach => solutionApproach;
  String get getExpectedTimeComplexity => expectedTimeComplexity ?? '';
  String get getExpectedSpaceComplexity => expectedSpaceComplexity ?? '';
  String get getWhatYouLearn => whatYouLearn ?? '';
  String get getKeyPattern => keyPattern ?? '';
  List<String> get getPrerequisites => prerequisites ?? [];
  List<String> get getFollowUpConcepts => followUpConcepts ?? [];
  List<String> get getCommonMistakes => commonMistakes ?? [];
  List<SimilarQuestion> get getSimilarQuestions => similarQuestions ?? [];
  ProblemStatus get getProblemStatus => problemStatus ?? ProblemStatus.none;
  bool get isSolved => getProblemStatus == ProblemStatus.solved;
  bool get getIsBookmarked => isBookmarked ?? false;
  List<ProblemSolutionStatusDTO> get getSolutionsStatus => solutionsStatus ?? [];
}
