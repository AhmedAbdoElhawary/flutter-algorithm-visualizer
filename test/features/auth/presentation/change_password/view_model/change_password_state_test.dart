import 'package:algorithm_visualizer/core/enums/notifier_state.dart';
import 'package:algorithm_visualizer/features/auth/presentation/change_password/view_model/change_password_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the status getters follow the status', () {
    const state = ChangePasswordState();

    expect([state.isLoading, state.isSuccess, state.isError], everyElement(isFalse));
    expect(state.copyWith(status: NotifierStatus.loading).isLoading, isTrue);
    expect(state.copyWith(status: NotifierStatus.success).isSuccess, isTrue);
    expect(state.copyWith(status: NotifierStatus.error).isError, isTrue);
  });

  test('copyWith keeps, changes and clears', () {
    final full = const ChangePasswordState().copyWith(
      currentPassword: 'a',
      newPassword: 'b',
      confirmPassword: 'c',
      currentPasswordError: 'x',
      newPasswordError: 'y',
      confirmPasswordError: 'z',
      errorMessage: 'error',
    );

    final kept = full.copyWith();
    expect([kept.currentPassword, kept.newPassword, kept.confirmPassword], ['a', 'b', 'c']);
    expect([kept.currentPasswordError, kept.newPasswordError, kept.confirmPasswordError, kept.errorMessage],
        ['x', 'y', 'z', 'error']);

    final cleared = full.copyWith(
      clearCurrentPasswordError: true,
      clearNewPasswordError: true,
      clearConfirmPasswordError: true,
      clearErrorMessage: true,
    );
    expect(
      [cleared.currentPasswordError, cleared.newPasswordError, cleared.confirmPasswordError, cleared.errorMessage],
      everyElement(isNull),
    );
  });
}
