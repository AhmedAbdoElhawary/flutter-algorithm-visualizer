import 'dart:async';

import 'package:algorithm_visualizer/features/challenge/data/models/test_case.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/usecases/grade_code_usecase.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/challenges_notifier.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/challenges_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fakes/fake_problem_repository.dart';
import '../../../../../helpers/test_container.dart';
import '../../../../../helpers/test_data.dart';

/// Holds each write until the test lets it finish.
class _SlowRepository extends FakeProblemRepository {
  final gate = Completer<void>();

  @override
  Future<void> updateProblem(CodingProblem problem) async {
    await gate.future;
    return super.updateProblem(problem);
  }
}

void main() {
  final twoSum = buildTestProblem(problemId: 1, name: 'Two Sum');
  final parens = buildTestProblem(problemId: 2, name: 'Valid Parentheses', difficulty: ProblemDifficulty.medium);

  late FakeProblemRepository repository;
  late ProviderContainer container;
  late ChallengesNotifier notifier;

  void build({FakeProblemRepository? using}) {
    repository = using ?? FakeProblemRepository();
    container = createTestContainer(
      signedInAs: buildTestUser(),
      overrides: [
        problemRepositoryProvider.overrideWithValue(repository),
        problemsProvider.overrideWithBuild((ref, notifier) => AsyncValue.data([twoSum, parens])),
      ],
    );
    container.listen(challengesProvider, (previous, next) {});
    notifier = container.read(challengesProvider.notifier);
  }

  CodingProblem inList(int id) =>
      container.read(problemsProvider).value!.firstWhere((problem) => problem.problemId == id);

  group('filter, search and the open card', () {
    setUp(build);

    test('changing the filter or search closes the open card', () {
      notifier.toggleExpanded(1);
      notifier.setFilter(ProblemDifficulty.easy);
      expect(container.read(challengesProvider).expandedId, 0);

      notifier.toggleExpanded(1);
      notifier.setSearch('two');
      expect(container.read(challengesProvider).expandedId, 0);
      expect(container.read(challengesProvider).search, 'two');

      notifier.toggleExpanded(1);
      notifier.clearSearch();
      expect(container.read(challengesProvider).expandedId, 0);
      expect(container.read(challengesProvider).search, '');
      expect(container.read(challengesProvider).filter, ProblemDifficulty.easy);
    });

    test('one card open at a time; tapping it again closes it', () {
      notifier.toggleExpanded(1);
      notifier.toggleExpanded(2);
      expect(container.read(challengesProvider).expandedId, 2);

      notifier.toggleExpanded(2);
      expect(container.read(challengesProvider).expandedId, 0);
    });

    test('every difficulty is a filter tab', () {
      expect(ChallengesNotifier.filters, ProblemDifficulty.values);
    });
  });

  group('changes to a problem', () {
    setUp(build);

    test('bookmarking saves it, updates the list, and flags it for sync', () async {
      await container.read(unsyncedProblemsProvider).needsToBeUploaded(1);

      await notifier.toggleBookmark(twoSum);

      expect(repository.updated.single.getIsBookmarked, isTrue);
      expect(inList(1).getIsBookmarked, isTrue);
      expect(container.read(problemSyncProvider).hasUnsyncedChanges, isTrue);

      await notifier.toggleBookmark(inList(1));
      expect(inList(1).getIsBookmarked, isFalse);
    });

    test('a graded run is saved onto the problem in the list', () async {
      const result = CodeGradeResult(
        allTestCaseResults: [TestCaseResult(input: '', expectedOutput: '', actualOutput: '', passed: true)],
        totalCount: 1,
        code: 'mine',
      );

      await notifier.updateProblemSubmission(twoSum, result);

      expect(inList(1).isSolved, isTrue);
      expect(inList(1).getSolutionsStatus.single.code, 'mine');
    });

    test('deleting removes it from the list', () async {
      await notifier.deleteProblem(2);

      expect(container.read(problemsProvider).value!.map((problem) => problem.problemId), [1]);
    });
  });

  test('leaving mid-save writes nothing back to a list no one is showing', () async {
    final slow = _SlowRepository();
    build(using: slow);
    final subscription = container.listen(challengesProvider, (previous, next) {});
    final notifier = container.read(challengesProvider.notifier);

    final saving = notifier.toggleBookmark(twoSum);
    subscription.close();
    container.dispose();
    slow.gate.complete();

    await expectLater(saving, completes);
  });

  test('its search box controller is disposed with it', () {
    build();
    final controller = notifier.textController;

    container.dispose();

    expect(() => controller.addListener(() {}), throwsFlutterError);
  });
}
