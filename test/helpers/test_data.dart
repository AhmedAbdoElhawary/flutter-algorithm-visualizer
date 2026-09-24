import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/example.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/similar_question.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';

CodingProblem buildTestProblem({
  int problemId = 1,
  String name = 'Two Sum',
  ProblemDifficulty difficulty = ProblemDifficulty.easy,
  List<String> tags = const ['Array', 'Hash Map'],
  String description = 'Given an array of integers, return indices of the two numbers.',
  List<String> constraints = const ['1 <= n <= 10^4'],
  List<Example> examples = const [],
  List<String> hints = const [],
  List<SimilarQuestion> similarQuestions = const [],
}) {
  return CodingProblem(
    number: problemId,
    problemId: problemId,
    name: name,
    source: 'Test',
    sourceProblemNumber: problemId,
    difficulty: difficulty,
    category: 'Arrays',
    tags: tags,
    patterns: const [],
    description: description,
    constraints: constraints,
    functionSignature: null,
    defaultCode: null,
    customObjects: null,
    examples: examples,
    edgeCases: const [],
    testCases: const [],
    hiddenTestCases: const [],
    hints: hints,
    solutionApproach: null,
    expectedTimeComplexity: 'O(n)',
    expectedSpaceComplexity: 'O(1)',
    whatYouLearn: 'Testing',
    keyPattern: 'Test pattern',
    prerequisites: const [],
    followUpConcepts: const [],
    commonMistakes: const [],
    similarQuestions: similarQuestions,
    problemStatus: ProblemStatus.none,
    isBookmarked: false,
    solutionsStatus: const [],
  );
}

AuthUser buildTestUser({String id = 'uid-1', String? name = 'Ada Lovelace', String? email = 'ada@test.dev'}) {
  return AuthUser(id: id, name: name, email: email);
}

ProblemStorageDTO buildTestProblemStorage({
  int? problemId = 1,
  ProblemStatus? problemStatus = ProblemStatus.none,
  bool? isBookmarked = false,
  List<ProblemSolutionStatusDTO>? solutionsStatus = const [],
}) {
  return ProblemStorageDTO(
    problemId: problemId,
    problemStatus: problemStatus,
    isBookmarked: isBookmarked,
    solutionsStatus: solutionsStatus,
  );
}
