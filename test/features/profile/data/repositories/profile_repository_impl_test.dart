import 'package:algorithm_visualizer/features/auth/data/data_sources/local/auth_local_data_source.dart';
import 'package:algorithm_visualizer/features/auth/data/models/auth_user_dto.dart';
import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';
import 'package:algorithm_visualizer/features/profile/data/data_sources/local/profile_local_data_source.dart';
import 'package:algorithm_visualizer/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes/fake_profile_remote_data_source.dart';
import '../../../../helpers/fakes/in_memory_storage.dart';
import '../../../../helpers/test_data.dart';

void main() {
  const cached = AuthUserDTO(id: 'uid-1', name: 'Ada', email: 'ada@test.dev');
  late FakeProfileRemoteDataSource remote;
  late AuthLocalDataSourceImpl authLocal;
  late ProfileLocalDataSourceImpl profileLocal;
  late ProfileRepositoryImpl repository;

  setUp(() {
    remote = FakeProfileRemoteDataSource(password: 'secret-1');
    authLocal = AuthLocalDataSourceImpl(InMemoryStorage());
    profileLocal = ProfileLocalDataSourceImpl(InMemoryStorage());
    repository = ProfileRepositoryImpl(
      localDataSource: authLocal,
      profileLocalDataSource: profileLocal,
      remoteDataSource: remote,
    );
  });

  void signIn() => remote.user = FakeUser(uid: cached.id, displayName: cached.name, email: cached.email);

  group('getCurrentUser', () {
    test('a guest with no name', () {
      expect(repository.getCurrentUser(), const AuthUser.guest());
    });

    test('a guest gets the name they picked on this device', () async {
      await profileLocal.saveDisplayName('Ada');

      expect(repository.getCurrentUser(), const AuthUser.guest(name: 'Ada'));
    });

    test('a signed-in user comes from Firebase', () {
      signIn();

      expect(repository.getCurrentUser(), const AuthUser(id: 'uid-1', name: 'Ada', email: 'ada@test.dev'));
    });
  });

  group('updateDisplayName', () {
    test('a guest keeps the name on this device and never calls Firebase', () async {
      await repository.updateDisplayName(displayName: ' Grace ');

      expect(profileLocal.getDisplayName(), 'Grace');
      expect(remote.calls, isEmpty);
    });

    test('a signed-in user updates Firebase and the cached user', () async {
      signIn();
      await authLocal.saveUser(cached);

      await repository.updateDisplayName(displayName: ' Grace ');

      expect(remote.user?.displayName, 'Grace');
      expect(authLocal.getUser()?.name, 'Grace');
      expect(profileLocal.getDisplayName(), isNull);
    });

    test('with no cached user, only Firebase changes', () async {
      signIn();

      await repository.updateDisplayName(displayName: 'Grace');

      expect(remote.user?.displayName, 'Grace');
      expect(authLocal.getUser(), isNull);
    });

    test('a Firebase failure throws and leaves the cached user alone', () async {
      signIn();
      await authLocal.saveUser(cached);
      remote.failWith = authError('network-request-failed');

      await expectLater(repository.updateDisplayName(displayName: 'Grace'), throwsException);

      expect(authLocal.getUser()?.name, 'Ada');
    });
  });

  group('updateEmail', () {
    test('asks Firebase and leaves the cached address until the link is opened', () async {
      signIn();
      await authLocal.saveUser(cached);

      await repository.updateEmail(newEmail: 'grace@test.dev', currentPassword: 'secret-1');

      expect(remote.calls, ['updateEmail']);
      expect(authLocal.getUser()?.email, 'ada@test.dev');
    });

    test('a wrong password throws', () async {
      signIn();

      await expectLater(
        repository.updateEmail(newEmail: 'grace@test.dev', currentPassword: 'wrong'),
        throwsException,
      );
    });
  });

  group('updatePassword', () {
    test('passes through to Firebase', () async {
      signIn();

      await repository.updatePassword(currentPassword: 'secret-1', newPassword: 'secret-2');

      expect(remote.password, 'secret-2');
    });

    test('a wrong password throws and keeps the old one', () async {
      signIn();

      await expectLater(
        repository.updatePassword(currentPassword: 'wrong', newPassword: 'secret-2'),
        throwsException,
      );
      expect(remote.password, 'secret-1');
    });
  });
}
