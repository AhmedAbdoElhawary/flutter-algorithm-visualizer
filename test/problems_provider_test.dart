import 'dart:async';

import 'package:algorithm_visualizer/features/challange/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challange/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challange/domain/repositories/problem_repository.dart';
import 'package:algorithm_visualizer/features/challange/presentation/view_model/challenges/challenges_providers.dart';
import 'package:algorithm_visualizer/features/challange/presentation/view_model/challenges/problems_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeProblemRepository implements ProblemRepository {
  _FakeProblemRepository(this.problems);

  final List<CodingProblem> problems;

  @override
  Future<List<CodingProblem>> getAllProblems() async => List.of(problems);

  @override
  Future<void> saveProblem(CodingProblem problem) async {}

  @override
  Future<void> updateProblem(CodingProblem problem) async {}

  @override
  Future<void> deleteProblem(int problemId) async {}
}

CodingProblem _problem(int id, ProblemStatus status) => CodingProblem(
      number: id,
      problemId: id,
      name: 'Problem $id',
      source: 'test',
      difficulty: ProblemDifficulty.easy,
      category: 'test',
      tags: const [],
      patterns: const [],
      description: 'desc',
      constraints: const [],
      functionSignature: null,
      examples: const [],
      edgeCases: const [],
      testCases: const [],
      hiddenTestCases: const [],
      hints: const [],
      solutionApproach: null,
      expectedTimeComplexity: '',
      expectedSpaceComplexity: '',
      whatYouLearn: '',
      keyPattern: '',
      prerequisites: const [],
      followUpConcepts: const [],
      commonMistakes: const [],
      similarQuestions: const [],
      problemStatus: status,
      isBookmarked: null,
      solutionsStatus: null,
    );

Future<void> _waitForLoad(ProviderContainer container) async {
  final completer = Completer<void>();
  final sub = container.listen<AsyncValue<List<CodingProblem>>>(
    problemsProvider,
    (_, next) {
      if (next.hasValue && !completer.isCompleted) completer.complete();
    },
    fireImmediately: true,
  );
  await completer.future.timeout(const Duration(seconds: 2));
  sub.close();
}

ProviderContainer _container(List<CodingProblem> problems) {
  final container = ProviderContainer(
    overrides: [
      problemRepositoryProvider.overrideWithValue(_FakeProblemRepository(problems)),
    ],
  );
  return container;
}

void main() {
  test('updateProblem patches only the matching problem and preserves other instances', () async {
    final p1 = _problem(1, ProblemStatus.none);
    final p2 = _problem(2, ProblemStatus.none);
    final container = _container([p1, p2]);
    addTearDown(container.dispose);
    await _waitForLoad(container);

    final updatedP1 = p1.copyWith(problemStatus: ProblemStatus.solved);
    container.read(problemsProvider.notifier).updateProblem(updatedP1);

    final problems = container.read(problemsProvider).value!;
    expect(problems, hasLength(2));
    expect(problems[0].problemStatus, ProblemStatus.solved);
    expect(identical(problems[1], p2), isTrue, reason: 'unrelated instance must be preserved');

    expect(container.read(getProblemProvider(1)).value?.problemStatus, ProblemStatus.solved);
    expect(container.read(getProblemProvider(2)).value, same(p2));
  });

  test('FilteredProblemIds compares by content, not list identity', () {
    const a = FilteredProblemIds([1, 2, 3]);
    const b = FilteredProblemIds([1, 2, 3]);
    const c = FilteredProblemIds([1, 2, 4]);

    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a == c, isFalse);
  });
}
