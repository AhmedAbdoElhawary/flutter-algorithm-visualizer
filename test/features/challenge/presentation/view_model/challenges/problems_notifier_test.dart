import 'package:algorithm_visualizer/core/enums/app_settings_enum.dart';
import 'package:algorithm_visualizer/core/helpers/storage/app_settings/app_settings_cubit.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
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

  test('deleting removes it', () async {
    await settle();

    container.read(problemsProvider.notifier).deleteProblem(1);

    expect(container.read(problemsProvider).value!.map((problem) => problem.problemId), [2]);
  });
}
