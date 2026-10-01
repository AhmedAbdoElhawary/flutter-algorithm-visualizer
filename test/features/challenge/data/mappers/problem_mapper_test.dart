import 'dart:convert';

import 'package:algorithm_visualizer/features/challenge/data/mappers/problem_mapper.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_dto.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../challenge_test_json.dart';

void main() {
  final dto = ProblemDTO.fromJson(fullProblemJson());

  test('copies every dataset field onto the problem', () {
    final problem = ProblemMapper.toDomain(dto, null);

    // The problem writes the dataset fields under the same keys, so each one must match.
    final problemJson = jsonDecode(jsonEncode(problem.toJson())) as Map<String, dynamic>;
    final dtoJson = jsonDecode(jsonEncode(dto.toJson())) as Map<String, dynamic>;
    for (final key in dtoJson.keys) {
      expect(problemJson[key], dtoJson[key], reason: key);
    }
  });

  test('with nothing saved, the progress is empty', () {
    final problem = ProblemMapper.toDomain(dto, null);

    expect(problem.problemStatus, isNull);
    expect(problem.isBookmarked, isNull);
    expect(problem.solutionsStatus, isNull);
  });

  test('the saved progress is laid over the dataset', () {
    const run = ProblemSolutionStatusDTO(code: 'x', isCorrect: true);
    const saved = ProblemStorageDTO(
      problemId: 7,
      problemStatus: ProblemStatus.solved,
      isBookmarked: true,
      solutionsStatus: [run],
    );

    final problem = ProblemMapper.toDomain(dto, saved);

    expect(problem.problemStatus, ProblemStatus.solved);
    expect(problem.isBookmarked, isTrue);
    expect(problem.solutionsStatus, [run]);
    expect(problem.name, 'Reverse Linked List');
  });

  test('a problem with no signature or starter code maps to nulls, not a crash', () {
    final bare = ProblemDTO.fromJson(<String, dynamic>{'problem_id': 1, 'name': 'Bare'});

    final problem = ProblemMapper.toDomain(bare, null);

    expect(problem.functionSignature, isNull);
    expect(problem.defaultCode, isNull);
    expect(problem.name, 'Bare');
  });
}
