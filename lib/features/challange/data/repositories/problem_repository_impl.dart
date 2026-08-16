import 'package:algorithm_visualizer/features/challange/data/data_sources/local/challenge_local_data_source.dart';
import 'package:algorithm_visualizer/features/challange/data/mappers/problem_mapper.dart';
import 'package:algorithm_visualizer/features/challange/data/models/problem_storage.dart';
import 'package:algorithm_visualizer/features/challange/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challange/domain/repositories/problem_repository.dart';
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

  // @override
  // Future<CodingProblem?> getProblem(int problemId) async {
  //   final problem = dataSource.getProblem(problemId);
  //   return problem != null ? ProblemMapper.toDomain(problem) : null;
  // }
}
