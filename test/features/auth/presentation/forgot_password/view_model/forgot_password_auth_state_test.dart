import 'package:algorithm_visualizer/core/enums/notifier_state.dart';
import 'package:algorithm_visualizer/features/auth/presentation/forgot_password/view_model/forgot_password_auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts empty and ready to send', () {
    const state = AuthForgotPasswordState();

    expect(state.email, '');
    expect(state.resendCountdown, 0);
    expect(state.canResend, isTrue);
  });

  test('cannot resend while the countdown runs', () {
    expect(const AuthForgotPasswordState(resendCountdown: 12).canResend, isFalse);
  });

  test('the status getters follow the status', () {
    const state = AuthForgotPasswordState();

    expect(state.copyWith(status: NotifierStatus.loading).isLoading, isTrue);
    expect(state.copyWith(status: NotifierStatus.success).isSuccess, isTrue);
    expect(state.copyWith(status: NotifierStatus.error).isError, isTrue);
  });

  test('copyWith keeps, changes and clears', () {
    final full = const AuthForgotPasswordState().copyWith(
      email: 'a@b.co',
      emailError: 'e',
      resendCountdown: 30,
      errorMessage: 'error',
      successMessage: 'ok',
    );

    final kept = full.copyWith();
    expect((kept.email, kept.emailError, kept.resendCountdown), ('a@b.co', 'e', 30));
    expect((kept.errorMessage, kept.successMessage), ('error', 'ok'));

    final cleared = full.copyWith(clearEmailError: true, clearErrorMessage: true, clearSuccessMessage: true);
    expect([cleared.emailError, cleared.errorMessage, cleared.successMessage], everyElement(isNull));
  });
}
