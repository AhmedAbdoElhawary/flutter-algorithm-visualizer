import 'package:algorithm_visualizer/core/enums/notifier_state.dart';
import 'package:algorithm_visualizer/features/auth/presentation/change_email/view_model/change_email_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the status getters follow the status', () {
    const state = ChangeEmailState();

    expect([state.isLoading, state.isSuccess, state.isError], everyElement(isFalse));
    expect(state.copyWith(status: NotifierStatus.loading).isLoading, isTrue);
    expect(state.copyWith(status: NotifierStatus.success).isSuccess, isTrue);
    expect(state.copyWith(status: NotifierStatus.error).isError, isTrue);
  });

  test('copyWith keeps, changes and clears', () {
    final full = const ChangeEmailState().copyWith(
      newEmail: 'a@b.co',
      currentPassword: 'secret',
      newEmailError: 'e',
      currentPasswordError: 'p',
      errorMessage: 'error',
    );

    final kept = full.copyWith();
    expect([kept.newEmail, kept.currentPassword, kept.newEmailError, kept.currentPasswordError, kept.errorMessage],
        ['a@b.co', 'secret', 'e', 'p', 'error']);

    final cleared =
        full.copyWith(clearNewEmailError: true, clearCurrentPasswordError: true, clearErrorMessage: true);
    expect([cleared.newEmailError, cleared.currentPasswordError, cleared.errorMessage], everyElement(isNull));
  });
}
