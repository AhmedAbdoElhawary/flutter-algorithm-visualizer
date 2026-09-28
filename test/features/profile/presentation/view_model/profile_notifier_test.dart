import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/profile_notifier.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes/fake_profile_remote_data_source.dart';
import '../../../../helpers/test_container.dart';
import '../../../../helpers/test_data.dart';

void main() {
  const ada = AuthUser(id: 'uid-1', name: 'Ada', email: 'ada@test.dev');

  /// Kept alive for the whole test, since the provider drops itself once nothing listens.
  ProviderContainer container({AuthUser? signedInAs}) {
    final container = createTestContainer(signedInAs: signedInAs);
    container.listen(profileProvider, (previous, next) {});
    return container;
  }

  group('build', () {
    test('a guest starts as a nameless guest', () {
      expect(container().read(profileProvider), const AuthUser.guest());
    });

    test('a signed-in user starts as themselves', () {
      expect(container(signedInAs: ada).read(profileProvider), ada);
    });
  });

  group('validateUpdateDisplayName', () {
    late ProfileNotifier notifier;

    setUp(() => notifier = container().read(profileProvider.notifier));

    for (final (name, valid) in [
      ('', false),
      ('   ', false),
      ('A', false),
      (' A ', false),
      ('Al', true),
      ('A' * ProfileNotifier.maxDisplayNameLength, true),
      ('A' * (ProfileNotifier.maxDisplayNameLength + 1), false),
    ]) {
      test('"${name.length > 10 ? '${name.length} letters' : name}" is ${valid ? 'valid' : 'not valid'}', () {
        expect(notifier.validateUpdateDisplayName(name: name), valid);
      });
    }
  });

  group('updateDisplayName', () {
    test('a guest keeps the new name locally and sees it straight away', () async {
      final c = container();

      final failure = await c.read(profileProvider.notifier).updateDisplayName(name: '  Grace ');

      expect(failure, isNull);
      expect(c.read(profileProvider), const AuthUser.guest(name: 'Grace'));
      expect(c.read(profileLocalDataSourceProvider).getDisplayName(), 'Grace');
    });

    test('a signed-in user renames the account', () async {
      final c = container(signedInAs: ada);

      final failure = await c.read(profileProvider.notifier).updateDisplayName(name: 'Grace');

      expect(failure, isNull);
      expect(c.read(profileProvider), ada.copyWith(name: 'Grace'));
      expect((c.read(profileRemoteDataSourceProvider) as FakeProfileRemoteDataSource).user?.displayName, 'Grace');
    });

    test('a name that is not valid is refused before reaching Firebase', () async {
      final c = container(signedInAs: ada);

      final failure = await c.read(profileProvider.notifier).updateDisplayName(name: 'A');

      expect(failure, StringsManager.notValidName);
      expect(c.read(profileProvider), ada);
      expect((c.read(profileRemoteDataSourceProvider) as FakeProfileRemoteDataSource).calls, isEmpty);
    });

    test('a Firebase failure comes back as its message and keeps the old name', () async {
      final c = container(signedInAs: ada);
      (c.read(profileRemoteDataSourceProvider) as FakeProfileRemoteDataSource).failWith =
          authError('network-request-failed');

      final failure = await c.read(profileProvider.notifier).updateDisplayName(name: 'Grace');

      expect(failure, StringsManager.networkError);
      expect(c.read(profileProvider), ada);
    });
  });
}
