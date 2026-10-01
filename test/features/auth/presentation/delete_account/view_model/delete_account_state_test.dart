import 'package:algorithm_visualizer/core/enums/notifier_state.dart';
import 'package:algorithm_visualizer/features/auth/presentation/delete_account/view_model/delete_account_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the status getters follow the status', () {
    const state = DeleteAccountState();

    expect([state.isLoading, state.isSuccess, state.isError], everyElement(isFalse));
    expect(state.copyWith(status: NotifierStatus.loading).isLoading, isTrue);
    expect(state.copyWith(status: NotifierStatus.success).isSuccess, isTrue);
    expect(state.copyWith(status: NotifierStatus.error).isError, isTrue);
  });

  test('copyWith keeps, changes and clears', () {
    final full = const DeleteAccountState().copyWith(password: 'secret', passwordError: 'p', errorMessage: 'error');

    final kept = full.copyWith();
    expect([kept.password, kept.passwordError, kept.errorMessage], ['secret', 'p', 'error']);

    final cleared = full.copyWith(clearPasswordError: true, clearErrorMessage: true);
    expect([cleared.passwordError, cleared.errorMessage], everyElement(isNull));
  });
}
