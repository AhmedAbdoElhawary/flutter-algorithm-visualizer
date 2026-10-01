import 'package:algorithm_visualizer/core/enums/notifier_state.dart';
import 'package:algorithm_visualizer/features/auth/presentation/login/view_model/login_auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts as an empty form', () {
    const state = AuthLoginState();

    expect((state.email, state.password, state.status), ('', '', NotifierStatus.initial));
    expect([state.emailError, state.passwordError, state.errorMessage, state.successMessage], everyElement(isNull));
  });

  test('the status getters follow the status', () {
    const state = AuthLoginState();

    expect(state.copyWith(status: NotifierStatus.loading).isLoading, isTrue);
    expect(state.copyWith(status: NotifierStatus.success).isSuccess, isTrue);
    expect(state.copyWith(status: NotifierStatus.error).isError, isTrue);
    expect([state.isLoading, state.isSuccess, state.isError], everyElement(isFalse));
  });

  test('copyWith keeps, changes and clears', () {
    final full = const AuthLoginState().copyWith(
      email: 'a@b.co',
      password: 'secret',
      emailError: 'e',
      passwordError: 'p',
      errorMessage: 'error',
      successMessage: 'ok',
    );

    expect(full.copyWith().email, 'a@b.co');
    expect(full.copyWith().password, 'secret');
    expect(full.copyWith().emailError, 'e');
    expect(full.copyWith().successMessage, 'ok');

    final cleared = full.copyWith(
      clearEmailError: true,
      clearPasswordError: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
    expect([cleared.emailError, cleared.passwordError, cleared.errorMessage, cleared.successMessage],
        everyElement(isNull));
  });
}
