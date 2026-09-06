import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/challenge_local_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/remote/challenge_remote_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/mappers/problem_mapper.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/repositories/problem_repository.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';

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

    await Future.wait([
      localDataSource.saveProblem(dto),
      _tryRemote(() => remoteDataSource.saveProblem(dto)),
    ]);
  }

  @override
  Future<void> updateProblem(CodingProblem problem) async {
    final dto = ProblemStorageDTO.fromJson(problem.toJson());

    await Future.wait([
      localDataSource.updateProblem(dto),
      _tryRemote(() => remoteDataSource.updateProblem(dto)),
    ]);
  }

  @override
  Future<void> deleteProblem(int problemId) async {
    await Future.wait([
      localDataSource.deleteProblem(problemId),
      _tryRemote(() => remoteDataSource.deleteProblem(problemId)),
    ]);
  }

  Future<List<ProblemStorageDTO>> _loadStorageProblems() async {
    if (!remoteDataSource.isSignedIn) return localDataSource.getProblems();

    try {
      final remoteProblems = await remoteDataSource.getProblems();
      await localDataSource.overwriteProblems(remoteProblems);
      return remoteProblems;
    } catch (_) {
      return localDataSource.getProblems();
    }
  }

  Future<void> _tryRemote(Future<void> Function() action) async {
    if (!remoteDataSource.isSignedIn) return;
    try {
      await action();
    } catch (e) {
      debugPrint("Something went wrong: $e");
    }
  }
}
