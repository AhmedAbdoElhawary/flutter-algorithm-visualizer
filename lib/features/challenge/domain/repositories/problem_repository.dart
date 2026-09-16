import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';

abstract class ProblemRepository {
  /// [arabic] selects the Arabic prose overlay. It is a parameter rather than
  /// something the repository reads for itself so the data layer keeps no
  /// opinion about the UI's current language.
  Future<List<CodingProblem>> getAllProblems({bool arabic = false});
  Future<void> saveProblem(CodingProblem problem);
  Future<void> updateProblem(CodingProblem problem);
  Future<void> deleteProblem(int problemId);
}
