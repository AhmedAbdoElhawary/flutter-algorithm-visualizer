import 'package:algorithm_visualizer/core/logging/firebase_log_config.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/remote/challenge_remote_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/remote/logging_challenge_remote_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/similar_question.dart';
import 'package:algorithm_visualizer/features/challenge/data/repositories/problem_repository_impl.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/test_container.dart';
import '../../../../../helpers/test_data.dart';

void main() {
  group('the real remote', () {
    for (final enabled in [false, true]) {
      test(enabled ? 'is wrapped in logging when logging is on' : 'is used bare when logging is off', () {
        final wasEnabled = FirebaseLogConfig.enabled;
        FirebaseLogConfig.enabled = enabled;
        addTearDown(() => FirebaseLogConfig.enabled = wasEnabled);
        final container = ProviderContainer();
        addTearDown(container.dispose);

        expect(
          container.read(problemRemoteDataSourceProvider),
          enabled ? isA<LoggingProblemRemoteDataSource>() : isA<ProblemRemoteDataSourceImpl>(),
        );
      });
    }
  });

  test('the repository is built on the local store, the remote and the unsynced marks', () {
    final container = createTestContainer();

    final repository = container.read(problemRepositoryProvider) as ProblemRepositoryImpl;
    expect(repository.localDataSource, same(container.read(problemLocalDataSourceProvider)));
    expect(repository.remoteDataSource, same(container.read(problemRemoteDataSourceProvider)));
    expect(repository.unsyncedProblems, same(container.read(unsyncedProblemsProvider)));
    expect(container.read(problemSyncServiceProvider), isNotNull);
  });

  group('with problems loaded', () {
    final similar = buildTestProblem(
      problemId: 1,
      similarQuestions: const [
        SimilarQuestion(problemId: 2, name: 'Known', reason: ''),
        SimilarQuestion(problemId: 99, name: 'Not in the dataset', reason: ''),
        SimilarQuestion(problemId: null, name: 'No id', reason: ''),
        SimilarQuestion(problemId: 0, name: 'Zero', reason: ''),
      ],
    );

    late ProviderContainer container;

    setUp(() {
      container = createTestContainer(
        overrides: [
          problemsProvider.overrideWithBuild(
            (ref, notifier) => AsyncValue.data([similar, buildTestProblem(problemId: 2, name: 'Known')]),
          ),
        ],
      );
    });

    test('a problem is found by id', () {
      expect(container.read(getProblemProvider(2)).value?.getName, 'Known');
    });

    test('an unknown or impossible id finds nothing', () {
      expect(container.read(getProblemProvider(42)).value, isNull);
      expect(container.read(getProblemProvider(0)).value, isNull);
      expect(container.read(getProblemProvider(-1)).value, isNull);
    });

    test('similar problems only link to ones that exist', () {
      expect(container.read(similarProblemIdsProvider(similar)), [2]);
    });
  });
}
