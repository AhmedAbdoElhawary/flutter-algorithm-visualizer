import 'package:algorithm_visualizer/features/challenge/data/data_sources/remote/challenge_remote_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';

import 'fake_remote.dart';

class FakeProblemRemoteDataSource with FakeRemote implements ProblemRemoteDataSource {
  FakeProblemRemoteDataSource({List<ProblemStorageDTO> problems = const [], this.isSignedIn = true})
      : problems = {for (final problem in problems) problem.problemId!: problem};

  /// Keyed by problem id, like the Firestore documents.
  final Map<int, ProblemStorageDTO> problems;

  @override
  bool isSignedIn;

  @override
  Future<List<ProblemStorageDTO>> getProblems() async {
    await answer('getProblems');
    return problems.values.toList();
  }

  @override
  Future<void> saveProblem(ProblemStorageDTO problem) async {
    await answer('saveProblem');
    if (problem.problemId != null) problems[problem.problemId!] = problem;
  }

  @override
  Future<void> updateProblem(ProblemStorageDTO problem) async {
    await answer('updateProblem');
    if (problem.problemId != null) problems[problem.problemId!] = problem;
  }

  @override
  Future<void> deleteProblem(int problemId) async {
    await answer('deleteProblem');
    problems.remove(problemId);
  }

  @override
  Future<void> batchSaveProblems(List<ProblemStorageDTO> problems) async {
    await answer('batchSaveProblems');
    for (final problem in problems) {
      if (problem.problemId != null) this.problems[problem.problemId!] = problem;
    }
  }

  @override
  Future<void> batchDeleteProblems(List<int> problemIds) async {
    await answer('batchDeleteProblems');
    problemIds.forEach(problems.remove);
  }

  @override
  Future<void> deleteAllProblems() async {
    await answer('deleteAllProblems');
    problems.clear();
  }
}
