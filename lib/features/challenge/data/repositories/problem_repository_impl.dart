import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/challenge_local_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/remote/challenge_remote_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/mappers/problem_mapper.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/repositories/problem_repository.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';

/// Routes the progress of a problem to whichever store owns it right now.
///
/// Signed out, everything lives in [localDataSource]: a guest is free to solve
/// and bookmark, and the local `problems` key is the only copy of that work.
/// Signed in, everything lives in [remoteDataSource] and Firestore's own cache
/// covers being offline, so the local key is deliberately left untouched: a
/// non-empty one always means "a guest session that has not been migrated yet".
class ProblemRepositoryImpl implements ProblemRepository {
  ProblemRepositoryImpl(this.localDataSource, this.remoteDataSource);

  final ProblemLocalDataSource localDataSource;
  final ProblemRemoteDataSource remoteDataSource;

  @override
  Future<List<CodingProblem>> getAllProblems() async {
    final assetsProblems = await localDataSource.loadProblemsAssets();
    final storageProblems = await _loadStorageProblems();

    final problems = assetsProblems.problems?.map((dto) {
      final localProblem = storageProblems.firstWhereOrNull((lp) => lp.problemId == dto.problemId);
      return ProblemMapper.toDomain(dto, localProblem);
    }).toList();

    return problems ?? [];
  }

  @override
  Future<void> saveProblem(CodingProblem problem) async {
    final dto = ProblemStorageDTO.fromJson(problem.toJson());

    if (!remoteDataSource.isSignedIn) return await localDataSource.saveProblem(dto);

    await _tryRemote(() => remoteDataSource.saveProblem(dto));
  }

  @override
  Future<void> updateProblem(CodingProblem problem) async {
    final dto = ProblemStorageDTO.fromJson(problem.toJson());

    if (!remoteDataSource.isSignedIn) return await localDataSource.updateProblem(dto);

    await _tryRemote(() => remoteDataSource.updateProblem(dto));
  }

  @override
  Future<void> deleteProblem(int problemId) async {
    if (!remoteDataSource.isSignedIn) return await localDataSource.deleteProblem(problemId);

    await _tryRemote(() => remoteDataSource.deleteProblem(problemId));
  }

  Future<List<ProblemStorageDTO>> _loadStorageProblems() async {
    if (!remoteDataSource.isSignedIn) return localDataSource.getProblems();

    return await remoteDataSource.getProblems();
  }

  Future<void> _tryRemote(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      debugPrint("Something went wrong: $e");
    }
  }
}
