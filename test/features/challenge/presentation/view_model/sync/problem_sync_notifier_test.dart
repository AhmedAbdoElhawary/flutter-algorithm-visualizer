import 'package:algorithm_visualizer/features/challenge/domain/services/problem_sync_service.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fakes/fake_problem_remote_data_source.dart';
import '../../../../../helpers/fakes/fake_problem_repository.dart';
import '../../../../../helpers/test_container.dart';
import '../../../../../helpers/test_data.dart';

void main() {
  late ProviderContainer container;
  late FakeProblemRemoteDataSource remote;

  setUp(() {
    container = createTestContainer(
      signedInAs: buildTestUser(),
      overrides: [problemRepositoryProvider.overrideWithValue(FakeProblemRepository())],
    );
    remote = container.read(problemRemoteDataSourceProvider) as FakeProblemRemoteDataSource;
  });

  test('starts idle, and knows about marks already waiting', () async {
    await container.read(unsyncedProblemsProvider).needsToBeUploaded(1);

    expect(container.read(problemSyncProvider).isSyncing, isFalse);
    expect(container.read(problemSyncProvider).hasUnsyncedChanges, isTrue);
  });

  test('a sync is busy while it runs, then idle with the marks cleared', () async {
    await container.read(unsyncedProblemsProvider).needsToBeUploaded(1);
    final running = container.read(problemSyncProvider.notifier).sync();

    expect(container.read(problemSyncProvider).isSyncing, isTrue);

    expect(await running, ProblemSyncResult.success);
    expect(container.read(problemSyncProvider).isSyncing, isFalse);
    expect(container.read(problemSyncProvider).hasUnsyncedChanges, isFalse);
  });

  test('a second sync while one runs does nothing', () async {
    final notifier = container.read(problemSyncProvider.notifier);

    final first = notifier.sync();
    final second = await notifier.sync();

    expect(second, ProblemSyncResult.failure);
    expect(await first, ProblemSyncResult.success);
    expect(remote.calls, ['getProblems']);
  });

  test('a failed sync ends idle and keeps the marks', () async {
    await container.read(unsyncedProblemsProvider).needsToBeUploaded(1);
    remote.failWith = Exception('offline');

    expect(await container.read(problemSyncProvider.notifier).sync(), ProblemSyncResult.failure);

    expect(container.read(problemSyncProvider).isSyncing, isFalse);
    expect(container.read(problemSyncProvider).hasUnsyncedChanges, isTrue);
  });

  test('the cooldown starts after a sync', () async {
    final notifier = container.read(problemSyncProvider.notifier);
    expect(notifier.remainingCooldown, Duration.zero);

    await notifier.sync();

    expect(notifier.remainingCooldown, greaterThan(Duration.zero));
  });

  test('refreshing picks up marks made elsewhere', () async {
    container.read(problemSyncProvider);
    await container.read(unsyncedProblemsProvider).needsToBeDeleted(3);

    container.read(problemSyncProvider.notifier).refreshUnsyncedFlag();

    expect(container.read(problemSyncProvider).hasUnsyncedChanges, isTrue);
  });
}
