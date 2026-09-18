import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';

abstract class ProblemRepository {
  Future<List<CodingProblem>> getAllProblems({bool arabic = false});
  Future<void> saveProblem(CodingProblem problem);
  Future<void> updateProblem(CodingProblem problem);
  Future<void> deleteProblem(int problemId);
}
