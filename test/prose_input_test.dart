import 'dart:convert';
import 'dart:io';

import 'package:algorithm_visualizer/features/challenge/data/mappers/problem_mapper.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/dataset.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/usecases/grade_code_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

List<CodingProblem> _load() {
  final raw = json.decode(File('assets/problems.json').readAsStringSync());
  final adaptive = <String, dynamic>{
    ...(raw['dataset'] as Map<String, dynamic>),
    'problems': raw['problems'],
  };
  final ds = Dataset.fromJson(adaptive);
  return [for (final d in ds.problems ?? []) ProblemMapper.toDomain(d, null)];
}

void main() {
  final problems = _load();
  const grade = GradeCodeUseCase();

  for (final name in ['Number of Islands', 'Rotting Oranges']) {
    test('prose/operation inputs on $name degrade without crashing', () {
      final p = problems.firstWhere((e) => e.name == name);
      final result = grade.grade(problem: p, userCode: '// empty');
      expect(result, isNotNull);
      expect(result.totalCount, greaterThan(0));
    });
  }

  test('well-formed grid inputs parse and grade a correct solution', () {
    final p = problems.firstWhere((e) => e.name == 'Number of Islands');
    final result = grade.grade(
      problem: p,
      userCode: '''
void _sink(List<List<String>> grid, int i, int j) {
  if (i < 0 || j < 0 || i >= grid.length || j >= grid[0].length || grid[i][j] != "1") return;
  grid[i][j] = "0";
  _sink(grid, i + 1, j);
  _sink(grid, i - 1, j);
  _sink(grid, i, j + 1);
  _sink(grid, i, j - 1);
}

int numIslands(List<List<String>> grid) {
  int count = 0;
  for (int i = 0; i < grid.length; i++) {
    for (int j = 0; j < grid[i].length; j++) {
      if (grid[i][j] == "1") {
        count++;
        _sink(grid, i, j);
      }
    }
  }
  return count;
}
''',
    );
    expect(result.passedCount, 11,
        reason: 'error=${result.error} passed=${result.passedCount}/${result.totalCount}');
    expect(result.error, isNull);
  });
}
