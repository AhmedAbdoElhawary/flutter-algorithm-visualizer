// Account deletion is the one operation in the app that cannot be undone, and
// the store policies require it to exist. What these tests pin down is not
// that it "works" but the *order* it works in — the sequence is the whole
// design, because each step destroys the thing the previous step needed.

import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';
import 'package:algorithm_visualizer/features/auth/domain/repositories/auth_repository.dart';
import 'package:algorithm_visualizer/features/auth/domain/services/account_deletion_service.dart';
import 'package:algorithm_visualizer/features/auth/domain/services/guest_data_service.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/challenge_local_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/unsynced_problems.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/services/problem_sync_service.dart';
import 'package:algorithm_visualizer/features/profile/data/data_sources/local/profile_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes/fake_problem_remote_data_source.dart';
import '../helpers/fakes/in_memory_storage.dart';

/// Every fake appends to this, so a test can assert on the whole sequence
/// rather than on each collaborator in isolation.
late List<String> log;

void main() {
  late InMemoryStorage storage;
  late ProblemLocalDataSource problemLocal;
  late ProfileLocalDataSource profileLocal;
  late FakeProblemRemoteDataSource problemRemote;
  late _FakeAuthRepository authRepository;
  late AccountDeletionService service;
  late ProblemSyncService sync;

  setUp(() {
    storage = InMemoryStorage();
    problemLocal = ProblemLocalDataSource(storage);
    profileLocal = ProfileLocalDataSourceImpl(storage);
    problemRemote = FakeProblemRemoteDataSource();
    log = problemRemote.calls;
    authRepository = _FakeAuthRepository();
    sync = ProblemSyncService(
      localDataSource: problemLocal,
      unsyncedProblems: UnsyncedProblems(storage),
      remoteDataSource: problemRemote,
      storage: storage,
    );
    service = AccountDeletionService(
      authRepository: authRepository,
      problemRemoteDataSource: problemRemote,
      guestDataService: GuestDataService(
        problemLocalDataSource: problemLocal,
        problemRemoteDataSource: problemRemote,
        unsyncedProblems: UnsyncedProblems(storage),
        problemSyncService: sync,
        profileLocalDataSource: profileLocal,
      ),
    );
  });

  test('Firestore is cleared while the credential is still alive, then the user', () async {
    await service.deleteAccount(password: 'correct horse');

    expect(log, <String>[
      'reauthenticate',
      'deleteAllProblems',
      'deleteFirebaseUser',
      'clearLocalUser',
    ]);
  });

  test('the password reaches the repository unchanged', () async {
    await service.deleteAccount(password: 's3cret');

    expect(authRepository.seenPassword, 's3cret');
  });

  test('local progress and display name are gone afterwards', () async {
    await profileLocal.saveDisplayName('Ahmed');
    await problemLocal.overwriteProblems(<ProblemStorageDTO>[
      const ProblemStorageDTO(
        problemId: 1,
        problemStatus: ProblemStatus.solved,
        isBookmarked: false,
        solutionsStatus: null,
      ),
    ]);

    await service.deleteAccount(password: 'correct horse');

    expect(profileLocal.getDisplayName(), isNull);
    expect(problemLocal.getProblems(), isEmpty);
  });

  test('the first download flag does not survive the deletion', () async {
    await sync.markFirstDownloadDone();

    await service.deleteAccount(password: 'correct horse');

    expect(sync.isFirstDownload, isFalse);
  });

  group('when the password is wrong', () {
    setUp(() => authRepository.failOnReauthenticate = true);

    test('it throws rather than reporting success', () {
      expect(
        () => service.deleteAccount(password: 'wrong'),
        throwsA(isA<Exception>()),
      );
    });

    test('nothing is destroyed — not Firestore, not the user, not local data', () async {
      await profileLocal.saveDisplayName('Ahmed');
      await problemLocal.overwriteProblems(<ProblemStorageDTO>[
        const ProblemStorageDTO(
          problemId: 1,
          problemStatus: ProblemStatus.solved,
          isBookmarked: false,
          solutionsStatus: null,
        ),
      ]);

      await expectLater(
        service.deleteAccount(password: 'wrong'),
        throwsA(isA<Exception>()),
      );

      expect(log, <String>['reauthenticate']);
      expect(profileLocal.getDisplayName(), 'Ahmed');
      expect(problemLocal.getProblems(), hasLength(1));
    });
  });

  test('a Firestore failure aborts before the user is deleted', () async {
    problemRemote.failWith = Exception('network');
    await profileLocal.saveDisplayName('Ahmed');

    await expectLater(
      service.deleteAccount(password: 'correct horse'),
      throwsA(isA<Exception>()),
    );

    expect(log, <String>['reauthenticate', 'deleteAllProblems']);
    expect(profileLocal.getDisplayName(), 'Ahmed');
  });
}

class _FakeAuthRepository implements AuthRepository {
  bool failOnReauthenticate = false;
  String? seenPassword;

  @override
  Future<void> deleteAccount({
    required String password,
    required Future<void> Function() onReauthenticated,
  }) async {
    seenPassword = password;
    log.add('reauthenticate');
    if (failOnReauthenticate) throw Exception('Invalid email or password');

    await onReauthenticated();

    log.add('deleteFirebaseUser');
    log.add('clearLocalUser');
  }

  @override
  Future<AuthUser> login({required String email, required String password}) => throw UnimplementedError();

  @override
  Future<AuthUser> register({required String name, required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<void> forgotPassword({required String email}) => throw UnimplementedError();

  @override
  Future<void> resetPassword({required String code, required String newPassword}) =>
      throw UnimplementedError();

  @override
  Future<void> logout() => throw UnimplementedError();
}
