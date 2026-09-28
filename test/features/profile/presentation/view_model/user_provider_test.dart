import 'package:algorithm_visualizer/core/logging/firebase_log_config.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/view_model/auth_providers.dart';
import 'package:algorithm_visualizer/features/profile/data/data_sources/local/profile_local_data_source.dart';
import 'package:algorithm_visualizer/features/profile/data/data_sources/remote/logging_profile_remote_data_source.dart';
import 'package:algorithm_visualizer/features/profile/data/data_sources/remote/profile_remote_data_source.dart';
import 'package:algorithm_visualizer/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_container.dart';

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
          container.read(profileRemoteDataSourceProvider),
          enabled ? isA<LoggingProfileRemoteDataSource>() : isA<ProfileRemoteDataSourceImpl>(),
        );
      });
    }
  });

  test('the repository is built on the storage and the remote', () {
    final container = createTestContainer();

    expect(container.read(profileLocalDataSourceProvider), isA<ProfileLocalDataSourceImpl>());
    final repository = container.read(profileRepositoryProvider) as ProfileRepositoryImpl;
    expect(repository.remoteDataSource, same(container.read(profileRemoteDataSourceProvider)));
    expect(repository.profileLocalDataSource, same(container.read(profileLocalDataSourceProvider)));
    expect(repository.localDataSource, same(container.read(authLocalDataSourceProvider)));
  });

  group('a guest', () {
    test('is not signed in and is anonymous until they pick a name', () {
      final container = createTestContainer();

      expect(container.read(currentUserProvider), const AuthUser.guest());
      expect(container.read(isSignedInProvider), isFalse);
      expect(container.read(currentUserNameProvider), StringsManager.anonymous);
    });

    test('shows the name they picked', () async {
      final container = createTestContainer();
      await container.read(profileLocalDataSourceProvider).saveDisplayName('Ada');

      expect(container.read(currentUserNameProvider), 'Ada');
    });
  });

  group('a signed-in user', () {
    test('is signed in and shows their name', () {
      final container = createTestContainer(signedInAs: const AuthUser(id: 'uid-1', name: 'Ada', email: null));

      expect(container.read(isSignedInProvider), isTrue);
      expect(container.read(currentUserNameProvider), 'Ada');
    });

    for (final (label, name) in [('no name', null), ('an empty name', ''), ('a blank name', '   ')]) {
      test('with $label is anonymous', () {
        final container = createTestContainer(signedInAs: AuthUser(id: 'uid-1', name: name, email: null));

        expect(container.read(currentUserNameProvider), StringsManager.anonymous);
      });
    }
  });
}
