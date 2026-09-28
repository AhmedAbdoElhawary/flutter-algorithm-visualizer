import 'package:algorithm_visualizer/core/enums/notifier_state.dart';
import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';
import 'package:algorithm_visualizer/features/auth/presentation/signup/view_model/signup_auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts as an empty form', () {
    const state = AuthSignUpState();

    expect([state.name, state.email, state.password, state.confirmPassword], everyElement(''));
    expect(state.status, NotifierStatus.initial);
    expect(state.user, isNull);
  });

  test('the status getters follow the status', () {
    const state = AuthSignUpState();

    expect(state.copyWith(status: NotifierStatus.loading).isLoading, isTrue);
    expect(state.copyWith(status: NotifierStatus.success).isSuccess, isTrue);
    expect(state.copyWith(status: NotifierStatus.error).isError, isTrue);
  });

  test('copyWith keeps, changes and clears', () {
    const user = AuthUser(id: 'uid-1', name: 'Ada', email: 'a@b.co');
    final full = const AuthSignUpState().copyWith(
      user: user,
      name: 'Ada',
      email: 'a@b.co',
      password: 'secret',
      confirmPassword: 'secret',
      nameError: 'n',
      emailError: 'e',
      passwordError: 'p',
      confirmPasswordError: 'c',
      errorMessage: 'error',
      successMessage: 'ok',
    );

    final kept = full.copyWith();
    expect(kept.user, user);
    expect([kept.name, kept.email, kept.password, kept.confirmPassword], ['Ada', 'a@b.co', 'secret', 'secret']);
    expect([kept.nameError, kept.emailError, kept.passwordError, kept.confirmPasswordError], ['n', 'e', 'p', 'c']);

    final cleared = full.copyWith(
      clearNameError: true,
      clearEmailError: true,
      clearPasswordError: true,
      clearConfirmPasswordError: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
    expect(
      [
        cleared.nameError,
        cleared.emailError,
        cleared.passwordError,
        cleared.confirmPasswordError,
        cleared.errorMessage,
        cleared.successMessage,
      ],
      everyElement(isNull),
    );
  });
}
