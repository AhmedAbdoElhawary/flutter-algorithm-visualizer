import 'package:algorithm_visualizer/core/enums/notifier_state.dart';
import 'package:algorithm_visualizer/core/exceptions/error_handler.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/auth/domain/services/account_deletion_service.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/view_model/auth_providers.dart';
import 'package:algorithm_visualizer/features/auth/presentation/delete_account/view_model/delete_account_state.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeleteAccountNotifier extends Notifier<DeleteAccountState> {
  late final AccountDeletionService _accountDeletionService;

  @override
  DeleteAccountState build() {
    _accountDeletionService = ref.watch(accountDeletionServiceProvider);

    return const DeleteAccountState();
  }

  void setPassword(String value) {
    state = state.copyWith(
      password: value,
      clearPasswordError: true,
      clearErrorMessage: true,
    );
  }

  bool validate() {
    final password = state.password;
    final error = password.isEmpty ? StringsManager.passwordRequired : null;

    state = state.copyWith(
      passwordError: error,
      clearPasswordError: error == null,
    );

    return error == null;
  }

  /// Runs the deletion. Returns whether the account is really gone, so the
  /// caller knows whether to navigate away.
  Future<bool> deleteAccount() async {
    if (!validate()) return false;

    /// Deleting signs the user out, which tears down the settings screen that
    /// keeps this auto-dispose notifier alive. Pin it, or `ref` is disposed
    /// mid-flight and every use after the first await throws — the same
    /// hazard `AuthLoginNotifier.logout` guards against.
    final keepAlive = ref.keepAlive();

    state = state.copyWith(status: NotifierStatus.loading, clearErrorMessage: true);

    try {
      await _accountDeletionService.deleteAccount(password: state.password);

      ref.invalidate(problemsProvider);
      ref.invalidate(profileProvider);

      state = state.copyWith(status: NotifierStatus.success, password: '');
      return true;
    } catch (e) {
      state = state.copyWith(
        status: NotifierStatus.error,
        errorMessage: ErrorHandler.mapErrorMessage(e),
      );
      return false;
    } finally {
      keepAlive.close();
    }
  }
}
