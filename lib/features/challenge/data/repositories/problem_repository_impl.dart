import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/challenge_local_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/problem_pending_local_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/remote/challenge_remote_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/mappers/problem_mapper.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/repositories/problem_repository.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';

class ProblemRepositoryImpl implements ProblemRepository {
  ProblemRepositoryImpl(this.localDataSource, this.remoteDataSource, this.pendingDataSource);

  final ProblemLocalDataSource localDataSource;
  final ProblemRemoteDataSource remoteDataSource;
  final ProblemPendingLocalDataSource pendingDataSource;

  @override
  Future<List<CodingProblem>> getAllProblems({bool arabic = false, bool forceRemote = false}) async {
    final assetsProblems = await localDataSource.loadProblemsAssets(arabic: arabic);
    final storageProblems = await _loadStorageProblems(forceRemote: forceRemote);

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

    await pendingDataSource.upsert(dto);
  }

  @override
  Future<void> updateProblem(CodingProblem problem) async {
    final dto = ProblemStorageDTO.fromJson(problem.toJson());

    if (!remoteDataSource.isSignedIn) return await localDataSource.updateProblem(dto);

    await pendingDataSource.upsert(dto);
  }

  @override
  Future<void> deleteProblem(int problemId) async {
    if (!remoteDataSource.isSignedIn) return await localDataSource.deleteProblem(problemId);

    await pendingDataSource.markDeleted(problemId);
  }

  Future<List<ProblemStorageDTO>> _loadStorageProblems({required bool forceRemote}) async {
    if (!remoteDataSource.isSignedIn) return localDataSource.getProblems();

    final synced = await _tryRemote(
      () => remoteDataSource.getProblems(preferCache: !forceRemote),
      fallback: const <ProblemStorageDTO>[],
    );

    return _withPendingOnTop(synced);
  }

  List<ProblemStorageDTO> _withPendingOnTop(List<ProblemStorageDTO> synced) {
    final byId = <int, ProblemStorageDTO>{
      for (final problem in synced)
        if (problem.problemId != null) problem.problemId!: problem,
    };

    for (final problem in pendingDataSource.getPending()) {
      if (problem.problemId != null) byId[problem.problemId!] = problem;
    }

    for (final problemId in pendingDataSource.getDeletedIds()) {
      byId.remove(problemId);
    }

    return byId.values.toList();
  }

  Future<T> _tryRemote<T>(Future<T> Function() action, {required T fallback}) async {
    try {
      return await action();
    } catch (e) {
      debugPrint("Something went wrong: $e");
      return fallback;
    }
  }
}
