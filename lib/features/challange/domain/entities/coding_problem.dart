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
import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'coding_problem.g.dart';

@JsonSerializable()
class CodingProblem {
  const CodingProblem({
    required this.number,
    required this.problemId,
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
    required this.problemStatus,
    required this.isBookmarked,
    required this.solutionsStatus,
  });

  final int? number;
  final int? problemId;
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
  final ProblemStatus? problemStatus;
  final bool? isBookmarked;
  final List<ProblemSolutionStatusDTO>? solutionsStatus;

  factory CodingProblem.fromJson(Map<String, dynamic> json) =>
      _$CodingProblemFromJson(json);

  Map<String, dynamic> toJson() => _$CodingProblemToJson(this);

  CodingProblem copyWith({
    int? number,
    int? problemId,
    String? name,
    String? source,
    int? sourceProblemNumber,
    ProblemDifficulty? difficulty,
    String? category,
    List<String>? tags,
    List<String>? patterns,
    String? description,
    List<String>? constraints,
    FunctionSignature? functionSignature,
    Map<String, String>? defaultCode,
    Map<String, List<CustomObject>>? customObjects,
    List<Example>? examples,
    List<String>? edgeCases,
    List<TestCase>? testCases,
    List<TestCase>? hiddenTestCases,
    List<String>? hints,
    SolutionApproach? solutionApproach,
    String? expectedTimeComplexity,
    String? expectedSpaceComplexity,
    String? whatYouLearn,
    String? keyPattern,
    List<String>? prerequisites,
    List<String>? followUpConcepts,
    List<String>? commonMistakes,
    List<SimilarQuestion>? similarQuestions,
    ProblemStatus? problemStatus,
    bool? isBookmarked,
    List<ProblemSolutionStatusDTO>? solutionsStatus,
  }) {
    return CodingProblem(
      number: number ?? this.number,
      problemId: problemId ?? this.problemId,
      name: name ?? this.name,
      source: source ?? this.source,
      sourceProblemNumber: sourceProblemNumber ?? this.sourceProblemNumber,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      patterns: patterns ?? this.patterns,
      description: description ?? this.description,
      constraints: constraints ?? this.constraints,
      functionSignature: functionSignature ?? this.functionSignature,
      defaultCode: defaultCode ?? this.defaultCode,
      customObjects: customObjects ?? this.customObjects,
      examples: examples ?? this.examples,
      edgeCases: edgeCases ?? this.edgeCases,
      testCases: testCases ?? this.testCases,
      hiddenTestCases: hiddenTestCases ?? this.hiddenTestCases,
      hints: hints ?? this.hints,
      solutionApproach: solutionApproach ?? this.solutionApproach,
      expectedTimeComplexity: expectedTimeComplexity ?? this.expectedTimeComplexity,
      expectedSpaceComplexity: expectedSpaceComplexity ?? this.expectedSpaceComplexity,
      whatYouLearn: whatYouLearn ?? this.whatYouLearn,
      keyPattern: keyPattern ?? this.keyPattern,
      prerequisites: prerequisites ?? this.prerequisites,
      followUpConcepts: followUpConcepts ?? this.followUpConcepts,
      commonMistakes: commonMistakes ?? this.commonMistakes,
      similarQuestions: similarQuestions ?? this.similarQuestions,
      problemStatus: problemStatus ?? this.problemStatus,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      solutionsStatus: solutionsStatus ?? this.solutionsStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodingProblem &&
          runtimeType == other.runtimeType &&
          number == other.number &&
          problemId == other.problemId &&
          name == other.name &&
          source == other.source &&
          sourceProblemNumber == other.sourceProblemNumber &&
          difficulty == other.difficulty &&
          category == other.category &&
          problemStatus == other.problemStatus &&
          isBookmarked == other.isBookmarked;

  @override
  int get hashCode => Object.hash(
        runtimeType,
        number,
        problemId,
        name,
        source,
        difficulty,
        category,
        problemStatus,
        isBookmarked,
      );
}

extension CodingProblemX on CodingProblem {
  int get getNumber => number ?? -1;
  int get getProblemId => problemId ?? -1;
  String get getName => name ?? '';

  String get getNameWithLanguageName {
    final snakeCase = getName.toSnakeCase.replaceAll(RegExp(r'\s+'), '_').toLowerCase();
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
  String get getDefaultCode {
    final code = defaultCode?['dart'];
    if (code == null || code.trim().isEmpty) return getFunctionInDart;
    return code;
  }
  String get getCode => solutionsStatus?.firstOrNull?.code ?? getDefaultCode;
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
  bool get isThereAnyCorrectCodeSaved =>
      getSolutionsStatus.firstWhereOrNull((element) => element.isCorrect == true) != null;
}
