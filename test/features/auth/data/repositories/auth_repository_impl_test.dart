import 'package:algorithm_visualizer/features/auth/data/data_sources/local/auth_local_data_source.dart';
import 'package:algorithm_visualizer/features/auth/data/models/auth_user_dto.dart';
import 'package:algorithm_visualizer/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes/fake_auth_remote_data_source.dart';
import '../../../../helpers/fakes/in_memory_storage.dart';
import '../../../../helpers/test_data.dart';

void main() {
  const user = AuthUserDTO(id: 'uid-1', name: 'Ada', email: 'ada@test.dev');
  late FakeAuthRemoteDataSource remote;
  late AuthLocalDataSourceImpl local;
  late AuthRepositoryImpl repository;

  setUp(() {
    remote = FakeAuthRemoteDataSource(accounts: {user.email: (user: user, password: 'secret-1')});
    local = AuthLocalDataSourceImpl(InMemoryStorage());
    repository = AuthRepositoryImpl(localDataSource: local, remoteDataSource: remote);
  });

  group('login', () {
    test('returns the user and remembers them on this device', () async {
      final signedIn = await repository.login(email: user.email, password: 'secret-1');

      expect(signedIn.id, user.id);
      expect(local.getUser()?.id, user.id);
    });

    test('a wrong password throws and remembers nobody', () async {
      await expectLater(repository.login(email: user.email, password: 'wrong'), throwsException);

      expect(local.getUser(), isNull);
    });
  });

  group('register', () {
    test('returns the new user and remembers them', () async {
      final created = await repository.register(name: 'Grace', email: 'grace@test.dev', password: 'secret-2');

      expect(created.name, 'Grace');
      expect(local.getUser()?.email, 'grace@test.dev');
    });

    test('an address in use throws and remembers nobody', () async {
      await expectLater(repository.register(name: 'Ada', email: user.email, password: 'x'), throwsException);

      expect(local.getUser(), isNull);
    });
  });

  test('forgot and reset password pass straight through', () async {
    await repository.forgotPassword(email: user.email);
    await repository.resetPassword(code: 'code', newPassword: 'secret-3');

    expect(remote.calls, ['forgotPassword', 'resetPassword']);

    remote.failWith = authError('expired-action-code');
    await expectLater(repository.resetPassword(code: 'old', newPassword: 'x'), throwsException);
  });

  test('logout forgets the user here and signs out of Firebase', () async {
    await repository.login(email: user.email, password: 'secret-1');

    await repository.logout();

    expect(local.getUser(), isNull);
    expect(remote.signedIn, isNull);
  });

  group('deleteAccount', () {
    setUp(() => repository.login(email: user.email, password: 'secret-1'));

    test('forgets the user only once Firebase has deleted them', () async {
      await repository.deleteAccount(password: 'secret-1', onReauthenticated: () async {});

      expect(remote.accounts, isEmpty);
      expect(local.getUser(), isNull);
    });

    test('a failed deletion keeps the user signed in here', () async {
      await expectLater(
        repository.deleteAccount(password: 'wrong', onReauthenticated: () async {}),
        throwsException,
      );

      expect(local.getUser()?.id, user.id);
    });
  });
}
