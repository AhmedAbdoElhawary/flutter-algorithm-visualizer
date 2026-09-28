import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/auth/presentation/change_email/view_model/change_email_provider.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fakes/fake_profile_remote_data_source.dart';
import '../../../../../helpers/test_container.dart';
import '../../../../../helpers/test_data.dart';

void main() {
  late ProviderContainer container;
  late FakeProfileRemoteDataSource remote;

  setUp(() {
    container = createTestContainer(signedInAs: buildTestUser());
    container.listen(changeEmailProvider, (previous, next) {});
    container.listen(profileProvider, (previous, next) {});
    remote = container.read(profileRemoteDataSourceProvider) as FakeProfileRemoteDataSource..password = 'secret-1';
  });

  Future<bool> request(String email, String password) {
    container.read(changeEmailProvider.notifier)
      ..setNewEmail(email)
      ..setCurrentPassword(password);
    return container.read(changeEmailProvider.notifier).requestEmailChange();
  }

  group('refuses before asking Firebase', () {
    for (final (email, password, emailError, passwordError) in [
      ('', '', StringsManager.newEmailRequired, StringsManager.currentPasswordRequired),
      ('grace', 'secret-1', StringsManager.invalidEmail, null),
      ('ADA@test.dev', 'secret-1', StringsManager.sameEmailAsCurrent, null),
    ]) {
      test('"$email"', () async {
        expect(await request(email, password), isFalse);

        final state = container.read(changeEmailProvider);
        expect((state.newEmailError, state.currentPasswordError), (emailError, passwordError));
        expect(remote.calls, isEmpty);
      });
    }
  });

  test('editing a field clears its error', () async {
    await request('', '');

    container.read(changeEmailProvider.notifier)
      ..setNewEmail('a')
      ..setCurrentPassword('b');

    final state = container.read(changeEmailProvider);
    expect([state.newEmailError, state.currentPasswordError, state.errorMessage], everyElement(isNull));
  });

  test('success sends the link and forgets the typed password', () async {
    expect(await request(' grace@test.dev ', 'secret-1'), isTrue);

    final state = container.read(changeEmailProvider);
    expect(state.isSuccess, isTrue);
    expect(state.currentPassword, '');
    expect(remote.calls, ['updateEmail']);
  });

  group('a refused change says why', () {
    for (final (name, error, message) in [
      ('in use', authError('email-already-in-use'), StringsManager.userAlreadyExists),
      ('sign-in too old', authError('requires-recent-login'), StringsManager.reauthenticateRequired),
      ('network down', authError('network-request-failed'), StringsManager.networkError),
    ]) {
      test(name, () async {
        remote.failWith = error;

        expect(await request('grace@test.dev', 'secret-1'), isFalse);

        expect(container.read(changeEmailProvider).isError, isTrue);
        expect(container.read(changeEmailProvider).errorMessage, message);
      });
    }

    test('wrong password', () async {
      expect(await request('grace@test.dev', 'wrong'), isFalse);

      expect(container.read(changeEmailProvider).errorMessage, StringsManager.invalidCredentials);
    });
  });

  test('loading while waiting, and a second submit meanwhile is ignored', () async {
    remote.delay = const Duration(milliseconds: 50);

    final first = request('grace@test.dev', 'secret-1');
    expect(container.read(changeEmailProvider).isLoading, isTrue);
    expect(await container.read(changeEmailProvider.notifier).requestEmailChange(), isFalse);

    expect(await first, isTrue);
    expect(remote.calls, ['updateEmail']);
  });
}
