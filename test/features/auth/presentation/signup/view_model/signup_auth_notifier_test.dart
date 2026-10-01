import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/view_model/auth_providers.dart';
import 'package:algorithm_visualizer/features/auth/presentation/signup/view_model/signup_auth_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fakes/fake_auth_remote_data_source.dart';
import '../../../../../helpers/test_container.dart';
import '../../../../../helpers/test_data.dart';

void main() {
  late ProviderContainer container;
  late FakeAuthRemoteDataSource remote;

  setUp(() {
    container = createTestContainer();
    remote = container.read(authRemoteDataSourceProvider) as FakeAuthRemoteDataSource;
  });

  void fill({
    String name = 'Grace Hopper',
    String email = 'grace@test.dev',
    String password = 'secret-1',
    String? confirm,
  }) {
    container.read(authSignupProvider.notifier)
      ..setName(name)
      ..setEmail(email)
      ..setPassword(password)
      ..setConfirmPassword(confirm ?? password);
  }

  String? nameErrorFor(String name) {
    fill(name: name);
    container.read(authSignupProvider.notifier).validateSignUp();
    return container.read(authSignupProvider).nameError;
  }

  group('the name', () {
    for (final (name, error) in [
      ('', StringsManager.nameRequired),
      ('   ', StringsManager.nameRequired),
      ('A', StringsManager.nameMinLength),
      ('A' * 50, null),
      ('A' * 51, StringsManager.nameMaxLength),
    ]) {
      test('"${name.length > 10 ? '${name.length} characters' : name}"', () {
        expect(nameErrorFor(name), error);
      });
    }

    group('a guest placeholder is refused', () {
      for (final name in ['Anonymous', 'anonymous ff 12', 'anon', 'Anon Coder', 'Guest', 'user_42', 'Player 7']) {
        test(name, () => expect(nameErrorFor(name), StringsManager.notValidName));
      }
    });

    test('a real name that starts like a placeholder is fine', () {
      expect(nameErrorFor('Guestina Lee'), isNull);
      expect(nameErrorFor('Userman'), isNull);
    });
  });

  group('the other fields', () {
    for (final (name, email, password, confirm, field, error) in [
      ('empty email', '', 'secret-1', 'secret-1', 'email', StringsManager.emailRequired),
      ('invalid email', 'grace', 'secret-1', 'secret-1', 'email', StringsManager.invalidEmail),
      ('empty password', 'grace@test.dev', '', '', 'password', StringsManager.passwordRequired),
      ('weak password', 'grace@test.dev', '12345', '12345', 'password', StringsManager.passwordMinLength),
      ('no confirmation', 'grace@test.dev', 'secret-1', '', 'confirm', StringsManager.confirmPasswordRequired),
      ('mismatch', 'grace@test.dev', 'secret-1', 'secret-2', 'confirm', StringsManager.passwordsDoNotMatch),
    ]) {
      test(name, () async {
        fill(email: email, password: password, confirm: confirm);

        expect(await container.read(authSignupProvider.notifier).register(), isFalse);

        final state = container.read(authSignupProvider);
        final errors = {
          'email': state.emailError,
          'password': state.passwordError,
          'confirm': state.confirmPasswordError,
        };
        expect(errors[field], error);
        expect(remote.calls, isEmpty);
      });
    }
  });

  test('editing a field clears its error', () {
    fill(name: '', email: '', password: '', confirm: '');
    container.read(authSignupProvider.notifier).validateSignUp();

    fill();

    final state = container.read(authSignupProvider);
    expect([state.nameError, state.emailError, state.passwordError, state.confirmPasswordError],
        everyElement(isNull));
  });

  test('success creates the account and moves the guest progress into it', () async {
    await container.read(profileLocalDataSourceProvider).saveDisplayName('Visitor');
    fill(email: ' grace@test.dev ');

    expect(await container.read(authSignupProvider.notifier).register(), isTrue);

    final state = container.read(authSignupProvider);
    expect(state.isSuccess, isTrue);
    expect(state.successMessage, StringsManager.registrationSuccess);
    expect(state.user?.email, 'grace@test.dev');
    expect(remote.accounts, contains('grace@test.dev'));
    expect(container.read(authLocalDataSourceProvider).getUser()?.name, 'Grace Hopper');
    expect(container.read(profileLocalDataSourceProvider).getDisplayName(), isNull);
  });

  test('an address already in use says so', () async {
    fill();
    await container.read(authSignupProvider.notifier).register();

    expect(await container.read(authSignupProvider.notifier).register(), isFalse);

    expect(container.read(authSignupProvider).errorMessage, StringsManager.userAlreadyExists);
  });

  test('a network failure says so', () async {
    remote.failWith = authError('network-request-failed');
    fill();

    expect(await container.read(authSignupProvider.notifier).register(), isFalse);

    expect(container.read(authSignupProvider).isError, isTrue);
    expect(container.read(authSignupProvider).errorMessage, StringsManager.networkError);
  });

  test('loading while waiting, and a second submit meanwhile is ignored', () async {
    remote.delay = const Duration(milliseconds: 50);
    fill();

    final first = container.read(authSignupProvider.notifier).register();
    expect(container.read(authSignupProvider).isLoading, isTrue);
    expect(await container.read(authSignupProvider.notifier).register(), isFalse);

    expect(await first, isTrue);
    expect(remote.calls, ['register']);
    expect(container.exists(problemsProvider), isFalse, reason: 'problems reload for the new account');
  });
}
