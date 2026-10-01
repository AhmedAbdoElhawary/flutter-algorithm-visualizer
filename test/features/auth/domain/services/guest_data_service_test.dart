import 'package:algorithm_visualizer/features/auth/domain/services/guest_data_service.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/challenge_local_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/unsynced_problems.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/services/problem_sync_service.dart';
import 'package:algorithm_visualizer/features/profile/data/data_sources/local/profile_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes/fake_problem_remote_data_source.dart';
import '../../../../helpers/fakes/in_memory_storage.dart';
import '../../../../helpers/test_data.dart';

void main() {
  late ProblemLocalDataSource problemLocal;
  late ProfileLocalDataSource profileLocal;
  late UnsyncedProblems unsynced;
  late FakeProblemRemoteDataSource remote;
  late ProblemSyncService sync;
  late GuestDataService service;

  setUp(() {
    final storage = InMemoryStorage();
    problemLocal = ProblemLocalDataSource(storage);
    profileLocal = ProfileLocalDataSourceImpl(storage);
    unsynced = UnsyncedProblems(storage);
    remote = FakeProblemRemoteDataSource(isSignedIn: false);
    sync = ProblemSyncService(
      localDataSource: problemLocal,
      unsyncedProblems: unsynced,
      remoteDataSource: remote,
      storage: storage,
    );
    service = GuestDataService(
      problemLocalDataSource: problemLocal,
      problemRemoteDataSource: remote,
      unsyncedProblems: unsynced,
      problemSyncService: sync,
      profileLocalDataSource: profileLocal,
    );
  });

  Future<void> solveAsGuest(List<int> ids) => problemLocal.overwriteProblems([
        for (final id in ids) buildTestProblemStorage(problemId: id, problemStatus: ProblemStatus.solved),
      ]);

  group('hasGuestData', () {
    test('a fresh guest has nothing to lose', () {
      expect(service.hasGuestData, isFalse);
    });

    test('solved problems or a chosen name count', () async {
      await solveAsGuest([1]);
      expect(service.hasGuestData, isTrue);

      await problemLocal.overwriteProblems(const []);
      await profileLocal.saveDisplayName('Visitor');
      expect(service.hasGuestData, isTrue);
      expect(service.guestName, 'Visitor');
    });

    test('a signed-in user is never a guest', () async {
      await solveAsGuest([1]);
      remote.isSignedIn = true;

      expect(service.hasGuestData, isFalse);
    });
  });

  group('merging into a new account', () {
    setUp(() => remote.isSignedIn = true);

    test('uploads the guest progress and drops the guest name', () async {
      await solveAsGuest([1, 2]);
      await profileLocal.saveDisplayName('Visitor');

      expect(await service.mergeGuestDataToTheAccount(), isTrue);

      expect(remote.problems.keys, unorderedEquals([1, 2]));
      expect(unsynced.needsToBeUploadedIds, isEmpty);
      expect(profileLocal.getDisplayName(), isNull);
      expect(sync.isFirstDownload, isTrue);
    });

    test('with nothing to move, downloads the account instead', () async {
      remote.problems[7] = buildTestProblemStorage(problemId: 7);

      expect(await service.mergeGuestDataToTheAccount(), isTrue);

      expect(remote.calls, ['getProblems']);
      expect(problemLocal.getProblems().map((p) => p.problemId), [7]);
    });

    test('a failed upload keeps the progress here, marked to upload again', () async {
      await solveAsGuest([1, 2]);
      remote.failWith = Exception('network');

      expect(await service.mergeGuestDataToTheAccount(), isFalse);

      expect(problemLocal.getProblems(), hasLength(2));
      expect(unsynced.needsToBeUploadedIds, unorderedEquals([1, 2]));
      expect(sync.isFirstDownload, isFalse);
    });
  });

  test('clearGuestData wipes progress, name, pending uploads and sync marks', () async {
    await solveAsGuest([1]);
    await profileLocal.saveDisplayName('Visitor');
    await unsynced.needsToBeUploaded(1);
    await sync.markFirstDownloadDone();
    await sync.setCurrentSync();

    await service.clearGuestData();

    expect(problemLocal.getProblems(), isEmpty);
    expect(profileLocal.getDisplayName(), isNull);
    expect(unsynced.hasAny, isFalse);
    expect(sync.isFirstDownload, isFalse);
    expect(sync.lastSync, isNull);
  });
}
