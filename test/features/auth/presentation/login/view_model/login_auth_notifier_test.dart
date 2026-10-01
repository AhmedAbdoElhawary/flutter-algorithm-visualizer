import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/auth/data/models/auth_user_dto.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/view_model/auth_providers.dart';
import 'package:algorithm_visualizer/features/auth/presentation/login/view_model/login_auth_provider.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fakes/fake_auth_remote_data_source.dart';
import '../../../../../helpers/test_container.dart';
import '../../../../../helpers/test_data.dart';

const _user = AuthUserDTO(id: 'uid-1', name: 'Ada', email: 'ada@test.dev');

void main() {
  late ProviderContainer container;
  late FakeAuthRemoteDataSource remote;

  setUp(() {
    container = createTestContainer();
    container.listen(authLoginProvider, (previous, next) {});
    remote = container.read(authRemoteDataSourceProvider) as FakeAuthRemoteDataSource;
    remote.accounts[_user.email] = (user: _user, password: 'secret-1');
  });

  Future<bool> login(String email, String password) {
    container.read(authLoginProvider.notifier)
      ..setEmail(email)
      ..setPassword(password);
    return container.read(authLoginProvider.notifier).login();
  }

  group('refuses before asking Firebase', () {
    for (final (email, password, emailError, passwordError) in [
      ('', '', StringsManager.emailRequired, StringsManager.passwordRequired),
      ('ada', 'secret-1', StringsManager.invalidEmail, null),
      (_user.email, '12345', null, StringsManager.passwordMinLength),
    ]) {
      test('"$email" / "$password"', () async {
        expect(await login(email, password), isFalse);

        final state = container.read(authLoginProvider);
        expect((state.emailError, state.passwordError), (emailError, passwordError));
        expect(remote.calls, isEmpty);
      });
    }
  });

  test('editing a field clears its error and the last failure', () async {
    await login('', '');
    remote.failWith = authError('network-request-failed');

    container.read(authLoginProvider.notifier).setEmail('a');
    container.read(authLoginProvider.notifier).setPassword('b');

    final state = container.read(authLoginProvider);
    expect([state.emailError, state.passwordError, state.errorMessage], everyElement(isNull));
  });

  test('success signs in, remembers the user, and drops what the guest had', () async {
    await container.read(profileLocalDataSourceProvider).saveDisplayName('Visitor');

    expect(await login(' ${_user.email} ', 'secret-1'), isTrue);

    final state = container.read(authLoginProvider);
    expect(state.isSuccess, isTrue);
    expect(state.successMessage, StringsManager.loginSuccess);
    expect(remote.signedIn?.id, _user.id);
    expect(container.read(authLocalDataSourceProvider).getUser()?.id, _user.id);
    expect(container.read(profileLocalDataSourceProvider).getDisplayName(), isNull);
  });

  group('a refused login says why', () {
    for (final (name, setup, message) in [
      ('wrong password', null, StringsManager.invalidCredentials),
      ('too many attempts', authError('too-many-requests'), StringsManager.tooManyAttempts),
      ('network down', authError('network-request-failed'), StringsManager.networkError),
    ]) {
      test(name, () async {
        remote.failWith = setup;

        expect(await login(_user.email, setup == null ? 'wrong-1' : 'secret-1'), isFalse);

        final state = container.read(authLoginProvider);
        expect(state.isError, isTrue);
        expect(state.errorMessage, message);
        expect(container.read(authLocalDataSourceProvider).getUser(), isNull);
      });
    }
  });

  test('loading while waiting, and a second submit meanwhile is ignored', () async {
    remote.delay = const Duration(milliseconds: 50);

    final first = login(_user.email, 'secret-1');
    expect(container.read(authLoginProvider).isLoading, isTrue);
    expect(await container.read(authLoginProvider.notifier).login(), isFalse);

    expect(await first, isTrue);
    expect(remote.calls, ['login']);
  });

  test('logout signs out, clears this device, and reloads the user as a guest', () async {
    await login(_user.email, 'secret-1');

    await container.read(authLoginProvider.notifier).logout();

    expect(remote.signedIn, isNull);
    expect(container.read(authLocalDataSourceProvider).getUser(), isNull);
    expect(container.read(isSignedInProvider), isFalse);
  });
}
