import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/challenge_local_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/unsynced_problems.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/remote/challenge_remote_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/mappers/problem_mapper.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/repositories/problem_repository.dart';
import 'package:collection/collection.dart';

/// local first for everybody, being signed in only adds a note in
/// [unsyncedProblems] that firestore has not got this one yet
class ProblemRepositoryImpl implements ProblemRepository {
  ProblemRepositoryImpl(this.localDataSource, this.remoteDataSource, this.unsyncedProblems);

  final ProblemLocalDataSource localDataSource;
  final ProblemRemoteDataSource remoteDataSource;
  final UnsyncedProblems unsyncedProblems;

  @override
  Future<List<CodingProblem>> getAllProblems({bool arabic = false}) async {
    final assetsProblems = await localDataSource.loadProblemsAssets(arabic: arabic);
    final storageProblems = localDataSource.getProblems();

    final problems = assetsProblems.problems?.map((dto) {
      final localProblem = storageProblems.firstWhereOrNull((lp) => lp.problemId == dto.problemId);
      return ProblemMapper.toDomain(dto, localProblem);
    }).toList();

    return problems ?? [];
  }

  @override
  Future<void> saveProblem(CodingProblem problem) async {
    final dto = ProblemStorageDTO.fromJson(problem.toJson());

    await localDataSource.saveProblem(dto);
    await _needsToBeUploaded(dto.problemId);
  }

  @override
  Future<void> updateProblem(CodingProblem problem) async {
    final dto = ProblemStorageDTO.fromJson(problem.toJson());

    await localDataSource.updateProblem(dto);
    await _needsToBeUploaded(dto.problemId);
  }

  @override
  Future<void> deleteProblem(int problemId) async {
    await localDataSource.deleteProblem(problemId);

    if (!remoteDataSource.isSignedIn) return;

    await unsyncedProblems.needsToBeDeleted(problemId);
  }

  Future<void> _needsToBeUploaded(int? problemId) async {
    if (problemId == null) return;
    if (!remoteDataSource.isSignedIn) return;

    await unsyncedProblems.needsToBeUploaded(problemId);
  }
}
