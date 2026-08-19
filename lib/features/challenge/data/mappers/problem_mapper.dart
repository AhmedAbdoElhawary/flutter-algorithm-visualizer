import 'package:algorithm_visualizer/features/challenge/data/models/problem_dto.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';

class ProblemMapper {
  static CodingProblem toDomain(ProblemDTO dto, ProblemStorageDTO? storage) {
    return CodingProblem(
      problemId: dto.problemId,
      number: dto.number,
      name: dto.name,
      source: dto.source,
      sourceProblemNumber: dto.sourceProblemNumber,
      difficulty: dto.difficulty,
      category: dto.category,
      tags: dto.tags,
      patterns: dto.patterns,
      description: dto.description,
      constraints: dto.constraints,
      functionSignature: dto.functionSignature,
      defaultCode: dto.defaultCode,
      customObjects: dto.customObjects,
      examples: dto.examples,
      edgeCases: dto.edgeCases,
      testCases: dto.testCases,
      hiddenTestCases: dto.hiddenTestCases,
      hints: dto.hints,
      solutionApproach: dto.solutionApproach,
      expectedTimeComplexity: dto.expectedTimeComplexity,
      expectedSpaceComplexity: dto.expectedSpaceComplexity,
      whatYouLearn: dto.whatYouLearn,
      keyPattern: dto.keyPattern,
      prerequisites: dto.prerequisites,
      followUpConcepts: dto.followUpConcepts,
      commonMistakes: dto.commonMistakes,
      similarQuestions: dto.similarQuestions,
      problemStatus: storage?.problemStatus,
      isBookmarked: storage?.isBookmarked,
      solutionsStatus: storage?.solutionsStatus,
    );
  }
}
