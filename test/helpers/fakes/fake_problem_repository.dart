import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/repositories/problem_repository.dart';

class FakeProblemRepository implements ProblemRepository {
  final List<CodingProblem> updated = [];

  @override
  Future<List<CodingProblem>> getAllProblems({bool arabic = false}) async => [];

  @override
  Future<void> saveProblem(CodingProblem problem) async {}

  @override
  Future<void> updateProblem(CodingProblem problem) async {
    updated.add(problem);
  }

  @override
  Future<void> deleteProblem(int problemId) async {}
}
