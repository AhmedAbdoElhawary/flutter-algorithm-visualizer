import 'package:algorithm_visualizer/core/storage/storage.dart';
import 'package:algorithm_visualizer/features/auth/domain/services/guest_data_service.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/challenge_local_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/unsynced_problems.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/remote/challenge_remote_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:algorithm_visualizer/features/challenge/data/repositories/problem_repository_impl.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/services/problem_sync_service.dart';
import 'package:algorithm_visualizer/features/profile/data/data_sources/local/profile_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _InMemoryStorage storage;
  late ProblemLocalDataSource local;
  late UnsyncedProblems unsynced;
  late _FakeRemote remote;
  late ProblemRepositoryImpl repository;
  late ProblemSyncService sync;

  late int firstId;
  late int secondId;

  setUp(() async {
    storage = _InMemoryStorage();
    local = ProblemLocalDataSource(storage);
    unsynced = UnsyncedProblems(storage);
    remote = _FakeRemote();
    repository = ProblemRepositoryImpl(local, remote, unsynced);
    sync = ProblemSyncService(
      localDataSource: local,
      unsyncedProblems: unsynced,
      remoteDataSource: remote,
      storage: storage,
    );

    final dataset = await local.loadProblemsAssets();
    firstId = dataset.problems![0].problemId!;
    secondId = dataset.problems![1].problemId!;
  });

  CodingProblem problem(int problemId, {bool isBookmarked = true}) {
    return CodingProblem(
      problemId: problemId,
      number: null,
      name: null,
      source: null,
      difficulty: null,
      category: null,
      tags: null,
      patterns: null,
      description: null,
      constraints: null,
      functionSignature: null,
      examples: null,
      edgeCases: null,
      testCases: null,
      hiddenTestCases: null,
      hints: null,
      solutionApproach: null,
      expectedTimeComplexity: null,
      expectedSpaceComplexity: null,
      whatYouLearn: null,
      keyPattern: null,
      prerequisites: null,
      followUpConcepts: null,
      commonMistakes: null,
      similarQuestions: null,
      problemStatus: ProblemStatus.solved,
      isBookmarked: isBookmarked,
      solutionsStatus: null,
    );
  }

  group('one store for everyone', () {
    test('a signed in bookmark lands in the same store a guest uses', () async {
      await repository.updateProblem(problem(firstId));

      expect(local.getProblems().single.problemId, firstId);
    });

    test('a guest writes the same way, just without owing anything', () async {
      remote.signedIn = false;

      await repository.updateProblem(problem(firstId));

      expect(local.getProblems().single.problemId, firstId);
      expect(unsynced.hasAny, isFalse);
    });

    test('a signed in write is marked as unsynced, and sends nothing', () async {
      await repository.updateProblem(problem(firstId));

      expect(unsynced.needsToBeUploadedIds, [firstId]);
      expect(remote.writes, isEmpty, reason: 'a bookmark must not cost a write');
    });

    test('reads never touch the network', () async {
      await repository.updateProblem(problem(firstId));
      remote.getProblemsCalls = 0;

      final problems = await repository.getAllProblems();

      expect(remote.getProblemsCalls, 0);
      expect(problems.firstWhere((p) => p.problemId == firstId).getIsBookmarked, isTrue);
    });

    test('a delete removes it locally and is marked as a tombstone', () async {
      await repository.updateProblem(problem(firstId));
      await repository.deleteProblem(firstId);

      expect(local.getProblems(), isEmpty);
      expect(unsynced.needsToBeDeletedIds, [firstId]);
      expect(unsynced.needsToBeUploadedIds, isEmpty, reason: 'an id is only ever in one list');
    });

    test('re-saving a deleted problem cancels the tombstone', () async {
      await repository.deleteProblem(firstId);
      await repository.updateProblem(problem(firstId));

      expect(unsynced.needsToBeDeletedIds, isEmpty);
      expect(unsynced.needsToBeUploadedIds, [firstId]);
    });
  });

  group('sync', () {
    test('uploads only what is unsynced, taking the data from local', () async {
      await repository.updateProblem(problem(firstId));
      await repository.updateProblem(problem(secondId));
      await repository.deleteProblem(secondId);

      expect(await sync.sync(), ProblemSyncResult.success);

      expect(remote.writes.single.problemId, firstId);
      expect(remote.deletes, [secondId]);
      expect(unsynced.hasAny, isFalse);
    });

    test('downloads the server picture into local afterwards', () async {
      remote.stored = [_dto(secondId)];

      await sync.sync();

      expect(local.getProblems().single.problemId, secondId);
    });

    test('a problem deleted on another device disappears from local', () async {
      await repository.updateProblem(problem(firstId));
      await sync.sync();

      remote.stored = [];
      await sync.clearLastSync();
      await sync.sync();

      expect(local.getProblems(), isEmpty);
    });

    test('a second press inside 30 seconds sends nothing', () async {
      await repository.updateProblem(problem(firstId));
      await sync.sync();

      await repository.updateProblem(problem(secondId));
      expect(await sync.sync(), ProblemSyncResult.cooldown);

      expect(remote.writes.length, 1);
      expect(unsynced.hasAny, isTrue, reason: 'the queued work must survive');
    });

    test('the cooldown is read back from storage, so a restart cannot skip it', () async {
      await sync.sync();

      final afterRestart = ProblemSyncService(
        localDataSource: local,
        unsyncedProblems: UnsyncedProblems(storage),
        remoteDataSource: remote,
        storage: storage,
      );

      expect(afterRestart.remainingCooldown, greaterThan(Duration.zero));
    });

    test('a failed push keeps every mark and costs no cooldown', () async {
      await repository.updateProblem(problem(firstId));
      remote.failWrites = true;

      expect(await sync.sync(), ProblemSyncResult.failure);

      expect(unsynced.needsToBeUploadedIds, [firstId]);
      expect(sync.remainingCooldown, Duration.zero);
      expect(local.getProblems().single.problemId, firstId, reason: 'local is untouched');
    });

    test('a guest has nothing to sync', () async {
      remote.signedIn = false;

      expect(await sync.sync(), ProblemSyncResult.notSignedIn);
    });
  });

  group('first download', () {
    test('an empty local store is filled from the server on first run', () async {
      remote.stored = [_dto(firstId)];

      await sync.downloadIfFirstRun();

      expect(local.getProblems().single.problemId, firstId);
    });

    test('it runs once, not on every launch', () async {
      await sync.downloadIfFirstRun();
      remote.getProblemsCalls = 0;

      await sync.downloadIfFirstRun();

      expect(remote.getProblemsCalls, 0);
    });

    test('a failure leaves the flag down so the next launch retries', () async {
      remote.failReads = true;

      await sync.downloadIfFirstRun();
      expect(sync.isFirstDownloadNull, isNull);

      remote.failReads = false;
      remote.stored = [_dto(firstId)];
      await sync.downloadIfFirstRun();

      expect(local.getProblems().single.problemId, firstId);
    });

    test('it never overwrites work that is not uploaded yet', () async {
      await repository.updateProblem(problem(firstId, isBookmarked: true));
      remote.stored = [_dto(firstId, isBookmarked: false)];

      await sync.downloadIfFirstRun();

      expect(local.getProblems().single.isBookmarked, isTrue);
    });

    test('a guest never downloads', () async {
      remote.signedIn = false;
      remote.stored = [_dto(firstId)];

      await sync.downloadIfFirstRun();

      expect(local.getProblems(), isEmpty);
    });
  });

  group('sign up migration', () {
    late GuestDataService guestService;

    setUp(() {
      guestService = GuestDataService(
        problemLocalDataSource: local,
        problemRemoteDataSource: remote,
        unsyncedProblems: unsynced,
        problemSyncService: sync,
        profileLocalDataSource: ProfileLocalDataSourceImpl(storage),
      );
    });

    test('the guest work is uploaded and kept as the account store', () async {
      remote.signedIn = false;
      await repository.updateProblem(problem(firstId));

      remote.signedIn = true;
      expect(await guestService.mergeGuestDataToTheAccount(), isTrue);

      expect(remote.writes.single.problemId, firstId);
      expect(local.getProblems().single.problemId, firstId, reason: 'local is not wiped');
      expect(unsynced.hasAny, isFalse);
    });

    test('a failed migration just leaves the marks up for the sync button', () async {
      remote.signedIn = false;
      await repository.updateProblem(problem(firstId));

      remote.signedIn = true;
      remote.failWrites = true;
      expect(await guestService.mergeGuestDataToTheAccount(), isFalse);

      expect(unsynced.needsToBeUploadedIds, [firstId], reason: 'no separate retry flag is needed');
      expect(local.getProblems().single.problemId, firstId);
    });

    test('a guest with no work gets the account picture instead', () async {
      remote.stored = [_dto(secondId)];

      expect(await guestService.mergeGuestDataToTheAccount(), isTrue);

      expect(local.getProblems().single.problemId, secondId);
    });

    test('hasGuestData asks auth, not the store', () async {
      await repository.updateProblem(problem(firstId));

      expect(guestService.hasGuestData, isFalse, reason: 'signed in, so it is his account store');

      remote.signedIn = false;
      expect(guestService.hasGuestData, isTrue);
    });
  });

  group('sign out', () {
    test('clears local, the marks and both flags', () async {
      final guestService = GuestDataService(
        problemLocalDataSource: local,
        problemRemoteDataSource: remote,
        unsyncedProblems: unsynced,
        problemSyncService: sync,
        profileLocalDataSource: ProfileLocalDataSourceImpl(storage),
      );

      await repository.updateProblem(problem(firstId));
      await sync.sync();

      await guestService.clearGuestData();

      expect(local.getProblems(), isEmpty);
      expect(unsynced.hasAny, isFalse);
      expect(sync.isFirstDownload, isFalse);
      expect(sync.lastSync == null, isTrue);
    });
  });
}

ProblemStorageDTO _dto(int problemId, {bool isBookmarked = true}) {
  return ProblemStorageDTO(
    problemId: problemId,
    problemStatus: ProblemStatus.solved,
    isBookmarked: isBookmarked,
    solutionsStatus: null,
  );
}

class _FakeRemote implements ProblemRemoteDataSource {
  bool signedIn = true;
  bool failWrites = false;
  bool failReads = false;

  List<ProblemStorageDTO> stored = <ProblemStorageDTO>[];

  final List<ProblemStorageDTO> writes = <ProblemStorageDTO>[];
  final List<int> deletes = <int>[];

  int getProblemsCalls = 0;

  @override
  bool get isSignedIn => signedIn;

  @override
  Future<List<ProblemStorageDTO>> getProblems() async {
    getProblemsCalls++;
    if (failReads) throw Exception('network');
    return stored;
  }

  @override
  Future<void> saveProblem(ProblemStorageDTO problem) async => writes.add(problem);

  @override
  Future<void> updateProblem(ProblemStorageDTO problem) async => writes.add(problem);

  @override
  Future<void> deleteProblem(int problemId) async => deletes.add(problemId);

  @override
  Future<void> batchSaveProblems(List<ProblemStorageDTO> problems) async {
    if (failWrites) throw Exception('network');
    writes.addAll(problems);
    stored = [
      ...stored.where((s) => !problems.any((p) => p.problemId == s.problemId)),
      ...problems,
    ];
  }

  @override
  Future<void> batchDeleteProblems(List<int> problemIds) async {
    if (failWrites) throw Exception('network');
    deletes.addAll(problemIds);
    stored = stored.where((s) => !problemIds.contains(s.problemId)).toList();
  }

  @override
  Future<void> deleteAllProblems() async => stored = <ProblemStorageDTO>[];
}

class _InMemoryStorage implements LocalStorage {
  final Map<String, Object?> _values = <String, Object?>{};

  @override
  Future<void> write<T>(String key, T value) async => _values[key] = value;

  @override
  T? read<T>(String key) => _values[key] as T?;

  @override
  Future<void> remove(String key) async => _values.remove(key);

  @override
  Future<void> clear() async => _values.clear();

  @override
  bool has(String key) => _values.containsKey(key);
}
