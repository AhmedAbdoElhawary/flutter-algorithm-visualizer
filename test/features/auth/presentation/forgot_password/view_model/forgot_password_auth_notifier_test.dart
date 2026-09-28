import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/view_model/auth_providers.dart';
import 'package:algorithm_visualizer/features/auth/presentation/forgot_password/view_model/forgot_password_auth_provider.dart';
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

  Future<bool> send(String email) {
    container.read(authForgotPasswordProvider.notifier).setEmail(email);
    return container.read(authForgotPasswordProvider.notifier).forgotPassword();
  }

  group('refuses before asking Firebase', () {
    for (final (email, error) in [('', StringsManager.emailRequired), ('ada', StringsManager.invalidEmail)]) {
      test('"$email"', () async {
        expect(await send(email), isFalse);

        expect(container.read(authForgotPasswordProvider).emailError, error);
        expect(remote.calls, isEmpty);
      });
    }
  });

  test('editing the address clears its error', () async {
    await send('');

    container.read(authForgotPasswordProvider.notifier).setEmail('a');

    expect(container.read(authForgotPasswordProvider).emailError, isNull);
  });

  test('a failure says why and starts no countdown', () async {
    remote.failWith = authError('network-request-failed');

    expect(await send('ada@test.dev'), isFalse);

    final state = container.read(authForgotPasswordProvider);
    expect(state.errorMessage, StringsManager.networkError);
    expect(state.canResend, isTrue);
  });

  test('loading while waiting, and a second submit meanwhile is ignored', () async {
    remote.delay = const Duration(milliseconds: 50);

    final first = send('ada@test.dev');
    expect(container.read(authForgotPasswordProvider).isLoading, isTrue);
    expect(await container.read(authForgotPasswordProvider.notifier).forgotPassword(), isFalse);

    expect(await first, isTrue);
    expect(remote.calls, ['forgotPassword']);
  });

  // The countdown ticks on a timer, so these run in fake time.
  testWidgets('a sent link starts a 60 second countdown that blocks resending', (tester) async {
    expect(await send(' ada@test.dev '), isTrue);

    var state = container.read(authForgotPasswordProvider);
    expect(state.successMessage, StringsManager.resetLinkSent);
    expect(state.resendCountdown, 60);

    await tester.pump(const Duration(seconds: 1));
    expect(container.read(authForgotPasswordProvider).resendCountdown, 59);

    expect(await container.read(authForgotPasswordProvider.notifier).resendEmail(), isFalse);
    expect(await container.read(authForgotPasswordProvider.notifier).forgotPassword(), isFalse,
        reason: 'the keyboard done key must respect the countdown too');
    expect(remote.calls, ['forgotPassword']);

    await tester.pump(const Duration(seconds: 59));
    state = container.read(authForgotPasswordProvider);
    expect(state.resendCountdown, 0);
    expect(state.canResend, isTrue);

    expect(await container.read(authForgotPasswordProvider.notifier).resendEmail(), isTrue);
    expect(remote.calls, ['forgotPassword', 'forgotPassword']);

    container.dispose();
    await tester.pump(const Duration(seconds: 61));
  });

  testWidgets('disposing mid-countdown stops the timer', (tester) async {
    await send('ada@test.dev');

    container.dispose();

    await tester.pump(const Duration(seconds: 61));
    expect(tester.takeException(), isNull);
  });
}
