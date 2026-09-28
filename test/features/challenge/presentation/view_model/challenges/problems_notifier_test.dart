import 'package:algorithm_visualizer/core/enums/app_settings_enum.dart';
import 'package:algorithm_visualizer/core/helpers/storage/app_settings/app_settings_cubit.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/test_case.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/usecases/grade_code_usecase.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fakes/fake_problem_remote_data_source.dart';
import '../../../../../helpers/fakes/fake_problem_repository.dart';
import '../../../../../helpers/test_container.dart';
import '../../../../../helpers/test_data.dart';

class _Repository extends FakeProblemRepository {
  List<CodingProblem> problems = [buildTestProblem(problemId: 1), buildTestProblem(problemId: 2)];
  Object? failWith;
  final List<bool> loads = [];

  @override
  Future<List<CodingProblem>> getAllProblems({bool arabic = false}) async {
    loads.add(arabic);
    final error = failWith;
    if (error != null) throw error;
    return problems;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _Repository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _Repository();
    container = createTestContainer(
      signedInAs: buildTestUser(),
      overrides: [problemRepositoryProvider.overrideWithValue(repository)],
    );
    container.listen(problemsProvider, (previous, next) {});
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('loads, then shows the problems', () async {
    expect(container.read(problemsProvider).isLoading, isTrue);

    await settle();

    expect(container.read(problemsProvider).value, hasLength(2));
    expect(repository.loads, [false]);
  });

  test('a failed load is an error, not a crash', () async {
    repository.failWith = Exception('broken asset');
    container.invalidate(problemsProvider);
    await settle();

    expect(container.read(problemsProvider).hasError, isTrue);
  });

  test('switching the app to Arabic reloads in Arabic', () async {
    await settle();

    await container.read(appSettingsProvider.notifier).changeLanguage(LanguagesEnum.arabic);
    container.read(problemsProvider);
    await settle();

    expect(repository.loads.last, isTrue);
  });

  test('the first load of an account on this device pulls its progress down first', () async {
    await settle();

    final remote = container.read(problemRemoteDataSourceProvider) as FakeProblemRemoteDataSource;
    expect(remote.calls, ['getProblems']);

    await container.read(problemsProvider.notifier).reload();
    expect(remote.calls, ['getProblems'], reason: 'only once');
  });

  test('updating replaces the problem with the same id, in place', () async {
    await settle();

    container.read(problemsProvider.notifier).updateProblem(buildTestProblem(problemId: 2, isBookmarked: true));

    final problems = container.read(problemsProvider).value!;
    expect(problems.map((problem) => problem.problemId), [1, 2]);
    expect(problems.last.getIsBookmarked, isTrue);
  });

  group('saving', () {
    CodingProblem inList(int id) =>
        container.read(problemsProvider).value!.firstWhere((problem) => problem.problemId == id);

    setUp(settle);

    test('a bookmark is saved, shown, and flagged for sync', () async {
      await container.read(unsyncedProblemsProvider).needsToBeUploaded(1);

      await container.read(problemsProvider.notifier).toggleBookmark(inList(1));

      expect(repository.updated.single.getIsBookmarked, isTrue);
      expect(inList(1).getIsBookmarked, isTrue);
      expect(container.read(problemSyncProvider).hasUnsyncedChanges, isTrue);

      await container.read(problemsProvider.notifier).toggleBookmark(inList(1));
      expect(inList(1).getIsBookmarked, isFalse);
    });

    test('a graded run is saved onto the problem and shown', () async {
      const result = CodeGradeResult(
        allTestCaseResults: [TestCaseResult(input: '', expectedOutput: '', actualOutput: '', passed: true)],
        totalCount: 1,
        code: 'mine',
      );

      await container.read(problemsProvider.notifier).updateProblemSubmission(inList(1), result);

      expect(inList(1).isSolved, isTrue);
      expect(inList(1).getSolutionsStatus.single.code, 'mine');
      expect(repository.updated.single.isSolved, isTrue);
    });

    test('deleting removes it from storage and the list', () async {
      await container.read(problemsProvider.notifier).deleteProblem(1);

      expect(container.read(problemsProvider).value!.map((problem) => problem.problemId), [2]);
    });

    test('a save that finishes after the app closed changes nothing and does not throw', () async {
      final notifier = container.read(problemsProvider.notifier);
      final saving = notifier.toggleBookmark(inList(1));
      container.dispose();

      await expectLater(saving, completes);
    });
  });
}
