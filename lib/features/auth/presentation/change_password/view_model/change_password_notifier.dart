import 'package:algorithm_visualizer/core/enums/notifier_state.dart';
import 'package:algorithm_visualizer/core/exceptions/error_handler.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/auth/presentation/change_password/view_model/change_password_state.dart';
import 'package:algorithm_visualizer/features/profile/domain/repositories/profile_repository.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangePasswordNotifier extends Notifier<ChangePasswordState> {
  late final ProfileRepository _profileRepository;

  @override
  ChangePasswordState build() {
    _profileRepository = ref.watch(profileRepositoryProvider);

    return const ChangePasswordState();
  }

  void setCurrentPassword(String value) {
    state = state.copyWith(
      currentPassword: value,
      clearCurrentPasswordError: true,
      clearErrorMessage: true,
    );
  }

  void setNewPassword(String value) {
    state = state.copyWith(
      newPassword: value,
      clearNewPasswordError: true,
      clearErrorMessage: true,
    );
  }

  void setConfirmPassword(String value) {
    state = state.copyWith(
      confirmPassword: value,
      clearConfirmPasswordError: true,
      clearErrorMessage: true,
    );
  }

  bool validate() {
    String? currentPasswordError;
    String? newPasswordError;
    String? confirmPasswordError;

    if (state.currentPassword.isEmpty) {
      currentPasswordError = StringsManager.currentPasswordRequired;
    }

    if (state.newPassword.isEmpty) {
      newPasswordError = StringsManager.newPasswordRequired;
    } else if (state.newPassword.length < 6) {
      newPasswordError = StringsManager.passwordMinLength;
    } else if (state.newPassword == state.currentPassword) {
      /// Firebase happily accepts a "change" to the same password. Catching it
      /// here spares the user a success message for a no-op.
      newPasswordError = StringsManager.samePasswordAsCurrent;
    }

    if (state.confirmPassword.isEmpty) {
      confirmPasswordError = StringsManager.confirmPasswordRequired;
    } else if (state.confirmPassword != state.newPassword) {
      confirmPasswordError = StringsManager.passwordsDoNotMatch;
    }

    state = state.copyWith(
      currentPasswordError: currentPasswordError,
      newPasswordError: newPasswordError,
      confirmPasswordError: confirmPasswordError,
      clearCurrentPasswordError: currentPasswordError == null,
      clearNewPasswordError: newPasswordError == null,
      clearConfirmPasswordError: confirmPasswordError == null,
    );

    return currentPasswordError == null && newPasswordError == null && confirmPasswordError == null;
  }

  /// Returns whether the password really changed, so the caller knows whether
  /// to close the dialog.
  Future<bool> changePassword() async {
    if (!validate()) return false;

    state = state.copyWith(status: NotifierStatus.loading, clearErrorMessage: true);

    try {
      await _profileRepository.updatePassword(
        currentPassword: state.currentPassword,
        newPassword: state.newPassword,
      );

      /// Drop the typed secrets the moment they are no longer needed, so they
      /// do not sit in memory for as long as the settings screen is open.
      state = state.copyWith(
        status: NotifierStatus.success,
        currentPassword: '',
        newPassword: '',
        confirmPassword: '',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: NotifierStatus.error,
        errorMessage: ErrorHandler.mapErrorMessage(e),
      );
      return false;
    }
  }
}
