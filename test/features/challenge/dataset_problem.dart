import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/challenge_local_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/unsynced_problems.dart';
import 'package:algorithm_visualizer/features/challenge/data/repositories/problem_repository_impl.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';

import '../../helpers/fakes/fake_problem_remote_data_source.dart';
import '../../helpers/fakes/in_memory_storage.dart';

/// A real problem from `assets/problems.json`, as the app loads it. Needs the test binding for the asset.
Future<CodingProblem> datasetProblem(int problemId) async {
  final storage = InMemoryStorage();
  final repository = ProblemRepositoryImpl(
    ProblemLocalDataSource(storage),
    FakeProblemRemoteDataSource(isSignedIn: false),
    UnsyncedProblems(storage),
  );
  final problems = await repository.getAllProblems();
  return problems.firstWhere((problem) => problem.problemId == problemId);
}
