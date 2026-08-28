import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_notifier.dart';
import 'package:algorithm_visualizer/features/home/view_model/home_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('homeDataProvider', () {
    test('returns greeting and null continueProblem when there are no problems', () {
      final container = ProviderContainer(
        overrides: [
          problemsProvider.overrideWithBuild((ref, notifier) => const AsyncValue.data([])),
        ],
      );

      addTearDown(container.dispose);

      final result = container.read(homeDataProvider);

      expect(result.greeting, computeGreeting());
      expect(result.continueProblem, isNull);
    });

    test('returns the first unsolved problem when no problem was attempted', () {
      final firstProblem = _createProblem(
        problemId: 1,
        name: 'First Problem',
        problemStatus: ProblemStatus.none,
      );

      final secondProblem = _createProblem(
        problemId: 2,
        name: 'Second Problem',
        problemStatus: ProblemStatus.none,
      );

      final container = ProviderContainer(
        overrides: [
          problemsProvider.overrideWithBuild(
            (ref, notifier) => AsyncValue.data([
              firstProblem,
              secondProblem,
            ]),
          ),
        ],
      );

      addTearDown(container.dispose);

      final result = container.read(homeDataProvider);

      expect(result.continueProblem, firstProblem);
    });

    test('returns the first attempted unsolved problem', () {
      final attemptedProblem = _createProblem(
        problemId: 1,
        name: 'Attempted Problem',
        problemStatus: ProblemStatus.attempted,
        solutions: [
          _createSolution(),
        ],
      );

      final unattemptedProblem = _createProblem(
        problemId: 2,
        name: 'Unattempted Problem',
        problemStatus: ProblemStatus.none,
      );

      final container = ProviderContainer(
        overrides: [
          problemsProvider.overrideWithBuild(
            (ref, notifier) => AsyncValue.data([
              attemptedProblem,
              unattemptedProblem,
            ]),
          ),
        ],
      );

      addTearDown(container.dispose);

      final result = container.read(homeDataProvider);

      expect(result.continueProblem, attemptedProblem);
    });

    test('prefers an attempted problem over an earlier unattempted problem', () {
      final unattemptedProblem = _createProblem(
        problemId: 1,
        name: 'Unattempted Problem',
        problemStatus: ProblemStatus.none,
      );

      final attemptedProblem = _createProblem(
        problemId: 2,
        name: 'Attempted Problem',
        problemStatus: ProblemStatus.attempted,
        solutions: [
          _createSolution(),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          problemsProvider.overrideWithBuild(
            (ref, notifier) => AsyncValue.data([
              unattemptedProblem,
              attemptedProblem,
            ]),
          ),
        ],
      );

      addTearDown(container.dispose);

      final result = container.read(homeDataProvider);

      expect(result.continueProblem, attemptedProblem);
    });

    test('returns the first attempted problem when multiple problems were attempted', () {
      final firstAttempted = _createProblem(
        problemId: 1,
        name: 'First Attempted',
        problemStatus: ProblemStatus.attempted,
        solutions: [
          _createSolution(),
        ],
      );

      final secondAttempted = _createProblem(
        problemId: 2,
        name: 'Second Attempted',
        problemStatus: ProblemStatus.attempted,
        solutions: [
          _createSolution(),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          problemsProvider.overrideWithBuild(
            (ref, notifier) => AsyncValue.data([
              firstAttempted,
              secondAttempted,
            ]),
          ),
        ],
      );

      addTearDown(container.dispose);

      final result = container.read(homeDataProvider);

      expect(result.continueProblem, firstAttempted);
    });

    test('ignores solved problems even when they have submissions', () {
      final solvedProblem = _createProblem(
        problemId: 1,
        name: 'Solved Problem',
        problemStatus: ProblemStatus.solved,
        solutions: [
          _createSolution(),
        ],
      );

      final unsolvedProblem = _createProblem(
        problemId: 2,
        name: 'Unsolved Problem',
        problemStatus: ProblemStatus.none,
      );

      final container = ProviderContainer(
        overrides: [
          problemsProvider.overrideWithBuild(
            (ref, notifier) => AsyncValue.data([
              solvedProblem,
              unsolvedProblem,
            ]),
          ),
        ],
      );

      addTearDown(container.dispose);

      final result = container.read(homeDataProvider);

      expect(result.continueProblem, unsolvedProblem);
    });

    test('returns null when all problems are solved', () {
      final problems = [
        _createProblem(problemId: 1, problemStatus: ProblemStatus.solved),
        _createProblem(problemId: 2, problemStatus: ProblemStatus.solved),
      ];

      final container = ProviderContainer(
        overrides: [
          problemsProvider.overrideWithBuild(
            (ref, notifier) => AsyncValue.data(problems),
          ),
        ],
      );

      addTearDown(container.dispose);

      final result = container.read(homeDataProvider);

      expect(result.continueProblem, isNull);
    });

    test('returns a greeting while problems are loading', () {
      final container = ProviderContainer(
        overrides: [
          problemsProvider.overrideWithBuild(
            (ref, notifier) => const AsyncValue.loading(),
          ),
        ],
      );

      addTearDown(container.dispose);

      final result = container.read(homeDataProvider);

      expect(result.greeting, computeGreeting());
      expect(result.continueProblem, isNull);
    });

    test('returns a greeting and null continueProblem when loading fails', () {
      final container = ProviderContainer(
        overrides: [
          problemsProvider.overrideWithBuild(
            (ref, notifier) => AsyncValue.error(
              Exception('Failed to load problems'),
              StackTrace.current,
            ),
          ),
        ],
      );

      addTearDown(container.dispose);

      final result = container.read(homeDataProvider);

      expect(result.greeting, computeGreeting());
      expect(result.continueProblem, isNull);
    });

    test('does not select a solved problem as the continue problem', () {
      final solvedProblem = _createProblem(problemStatus: ProblemStatus.solved);

      final container = ProviderContainer(
        overrides: [
          problemsProvider.overrideWithBuild(
            (ref, notifier) => AsyncValue.data([solvedProblem]),
          ),
        ],
      );

      addTearDown(container.dispose);

      final result = container.read(homeDataProvider);

      expect(result.continueProblem, isNull);
    });

    test('uses the correct greeting for the current time', () {
      final container = ProviderContainer(
        overrides: [
          problemsProvider.overrideWithBuild(
            (ref, notifier) => const AsyncValue.data([]),
          ),
        ],
      );

      addTearDown(container.dispose);

      final result = container.read(homeDataProvider);

      expect(result.greeting, computeGreeting());
    });
  });
}

CodingProblem _createProblem({
  int problemId = 1,
  String name = 'Test Problem',
  ProblemDifficulty difficulty = ProblemDifficulty.easy,
  String category = 'Arrays',
  ProblemStatus problemStatus = ProblemStatus.none,
  bool isBookmarked = false,
  List<ProblemSolutionStatusDTO> solutions = const [],
}) {
  return CodingProblem(
    number: problemId,
    problemId: problemId,
    name: name,
    source: 'Test',
    sourceProblemNumber: problemId,
    difficulty: difficulty,
    category: category,
    tags: const [],
    patterns: const [],
    description: 'Test description',
    constraints: const [],
    functionSignature: null,
    defaultCode: null,
    customObjects: null,
    examples: const [],
    edgeCases: const [],
    testCases: const [],
    hiddenTestCases: const [],
    hints: const [],
    solutionApproach: null,
    expectedTimeComplexity: 'O(n)',
    expectedSpaceComplexity: 'O(1)',
    whatYouLearn: 'Testing',
    keyPattern: 'Test pattern',
    prerequisites: const [],
    followUpConcepts: const [],
    commonMistakes: const [],
    similarQuestions: const [],
    problemStatus: problemStatus,
    isBookmarked: isBookmarked,
    solutionsStatus: solutions,
  );
}

ProblemSolutionStatusDTO _createSolution({
  bool? isCorrect = false,
  DateTime? submittedAt,
}) {
  return ProblemSolutionStatusDTO(
    code: 'test code',
    allTestCaseResults: const [],
    isCorrect: isCorrect,
    submittedAt: submittedAt,
  );
}
