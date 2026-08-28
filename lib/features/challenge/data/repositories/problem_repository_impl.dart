import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/challenge_local_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/mappers/problem_mapper.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/repositories/problem_repository.dart';
import 'package:collection/collection.dart';

class ProblemRepositoryImpl implements ProblemRepository {
  final ProblemLocalDataSource dataSource;

  ProblemRepositoryImpl(this.dataSource);

  @override
  Future<List<CodingProblem>> getAllProblems() async {
    final assetsProblems = await dataSource.loadProblemsAssets();
    final localProblems = dataSource.getProblems();

    final problems = assetsProblems.problems?.map((dto) {
      final localProblem = localProblems.firstWhereOrNull((lp) => lp.problemId == dto.problemId);
      return ProblemMapper.toDomain(dto, localProblem);
    }).toList();

    return problems ?? [];
  }

  @override
  Future<void> saveProblem(CodingProblem problem) async {
    final dto = ProblemStorageDTO.fromJson(problem.toJson());
    await dataSource.saveProblem(dto);
  }

  @override
  Future<void> updateProblem(CodingProblem problem) async {
    final dto = ProblemStorageDTO.fromJson(problem.toJson());
    await dataSource.updateProblem(dto);
  }

  @override
  Future<void> deleteProblem(int problemId) async {
    await dataSource.deleteProblem(problemId);
  }
}
