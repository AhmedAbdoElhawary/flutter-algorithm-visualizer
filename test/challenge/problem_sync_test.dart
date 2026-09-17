import 'package:algorithm_visualizer/core/storage/storage.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/challenge_local_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/problem_pending_local_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/remote/challenge_remote_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:algorithm_visualizer/features/challenge/data/repositories/problem_repository_impl.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/services/problem_sync_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _InMemoryStorage storage;
  late ProblemLocalDataSource local;
  late ProblemPendingLocalDataSource pending;
  late _FakeRemote remote;
  late ProblemRepositoryImpl repository;
  late ProblemSyncService sync;

  late int firstProblemId;
  late int secondProblemId;

  setUp(() async {
    storage = _InMemoryStorage();
    local = ProblemLocalDataSource(storage);
    pending = ProblemPendingLocalDataSource(storage);
    remote = _FakeRemote();
    repository = ProblemRepositoryImpl(local, remote, pending);
    sync = ProblemSyncService(
      pendingDataSource: pending,
      remoteDataSource: remote,
      storage: storage,
    );

    final dataset = await local.loadProblemsAssets();
    firstProblemId = dataset.problems![0].problemId!;
    secondProblemId = dataset.problems![1].problemId!;
  });

  CodingProblem bookmarked(int problemId) {
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
      isBookmarked: true,
      solutionsStatus: null,
    );
  }

  group('signed in writes', () {
    test('a bookmark is queued locally and Firestore is never called', () async {
      await repository.updateProblem(bookmarked(firstProblemId));

      expect(pending.getPending().single.problemId, firstProblemId);
      expect(remote.writes, isEmpty, reason: 'a bookmark must not cost a write');
    });

    test('the guest store is left alone, so sign up migration still means what it meant', () async {
      await repository.updateProblem(bookmarked(firstProblemId));

      expect(local.getProblems(), isEmpty);
    });

    test('a delete is queued as a tombstone rather than sent', () async {
      await repository.deleteProblem(firstProblemId);

      expect(pending.getDeletedIds(), [firstProblemId]);
      expect(remote.deletes, isEmpty);
    });

    test('re-bookmarking a deleted problem cancels the tombstone', () async {
      await repository.deleteProblem(firstProblemId);
      await repository.updateProblem(bookmarked(firstProblemId));

      expect(pending.getDeletedIds(), isEmpty);
      expect(pending.getPending().single.problemId, firstProblemId);
    });

    test('a signed out guest still writes straight to the guest store', () async {
      remote.signedIn = false;

      await repository.updateProblem(bookmarked(firstProblemId));

      expect(local.getProblems().single.problemId, firstProblemId);
      expect(pending.getPending(), isEmpty);
    });
  });

  group('reads', () {
    test('an unsynced bookmark is visible even though the server has not heard of it', () async {
      await repository.updateProblem(bookmarked(firstProblemId));

      final problems = await repository.getAllProblems();
      final problem = problems.firstWhere((p) => p.problemId == firstProblemId);

      expect(problem.getIsBookmarked, isTrue);
    });

    test('a local change wins over the synced copy of the same problem', () async {
      remote.stored = [_dto(firstProblemId, isBookmarked: true)];

      /// The same problem, un-bookmarked on this device and not yet synced.
      await repository.updateProblem(bookmarked(firstProblemId).copyWith(isBookmarked: false));

      final problems = await repository.getAllProblems();
      final problem = problems.firstWhere((p) => p.problemId == firstProblemId);

      expect(problem.getIsBookmarked, isFalse);
    });

    test('a queued delete hides the synced copy', () async {
      remote.stored = [_dto(firstProblemId, isBookmarked: true)];

      await repository.deleteProblem(firstProblemId);

      final problems = await repository.getAllProblems();
      final problem = problems.firstWhere((p) => p.problemId == firstProblemId);

      expect(problem.getIsBookmarked, isFalse);
    });

    test('app open reads the cache, the sync button reads the server', () async {
      await repository.getAllProblems();
      expect(remote.lastPreferCache, isTrue);

      await repository.getAllProblems(forceRemote: true);
      expect(remote.lastPreferCache, isFalse);
    });
  });

  group('sync', () {
    test('pushes the queue in one batch and empties it', () async {
      await repository.updateProblem(bookmarked(firstProblemId));
      await repository.deleteProblem(secondProblemId);

      expect(await sync.sync(), ProblemSyncResult.success);

      expect(remote.writes.single.problemId, firstProblemId);
      expect(remote.deletes, [secondProblemId]);
      expect(pending.hasPendingChanges, isFalse);
    });

    test('a second press inside 30 seconds sends nothing', () async {
      await repository.updateProblem(bookmarked(firstProblemId));
      await sync.sync();

      await repository.updateProblem(bookmarked(secondProblemId));
      expect(await sync.sync(), ProblemSyncResult.cooldown);

      expect(remote.writes.length, 1, reason: 'the second press must not reach Firestore');
      expect(pending.hasPendingChanges, isTrue, reason: 'and must not lose the queued work');
    });

    test('the cooldown is read back from storage, so a restart cannot skip it', () async {
      await sync.sync();

      final afterRestart = ProblemSyncService(
        pendingDataSource: ProblemPendingLocalDataSource(storage),
        remoteDataSource: remote,
        storage: storage,
      );

      expect(afterRestart.remainingCooldown, greaterThan(Duration.zero));
    });

    test('a failed push keeps the queue and costs no cooldown', () async {
      await repository.updateProblem(bookmarked(firstProblemId));
      remote.failWrites = true;

      expect(await sync.sync(), ProblemSyncResult.failure);

      expect(pending.hasPendingChanges, isTrue);
      expect(sync.remainingCooldown, Duration.zero, reason: 'nothing was delivered to wait for');
    });

    test('a guest has nothing to sync', () async {
      remote.signedIn = false;

      expect(await sync.sync(), ProblemSyncResult.notSignedIn);
    });
  });
}

ProblemStorageDTO _dto(int problemId, {required bool isBookmarked}) {
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

  List<ProblemStorageDTO> stored = <ProblemStorageDTO>[];

  final List<ProblemStorageDTO> writes = <ProblemStorageDTO>[];
  final List<int> deletes = <int>[];

  bool? lastPreferCache;

  @override
  bool get isSignedIn => signedIn;

  @override
  Future<List<ProblemStorageDTO>> getProblems({bool preferCache = false}) async {
    lastPreferCache = preferCache;
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
  }

  @override
  Future<void> batchDeleteProblems(List<int> problemIds) async {
    if (failWrites) throw Exception('network');
    deletes.addAll(problemIds);
  }

  @override
  Future<void> deleteAllProblems() async {
    stored = <ProblemStorageDTO>[];
  }
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
