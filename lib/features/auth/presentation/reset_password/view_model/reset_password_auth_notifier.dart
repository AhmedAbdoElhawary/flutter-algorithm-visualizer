import 'package:algorithm_visualizer/core/enums/notifier_state.dart';
import 'package:algorithm_visualizer/core/exceptions/error_handler.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/auth/domain/repositories/auth_repository.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/view_model/auth_providers.dart';
import 'package:algorithm_visualizer/features/auth/presentation/reset_password/view_model/reset_password_auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthResetPasswordNotifier extends Notifier<AuthResetPasswordState> {
  late final AuthRepository _authRepository;

  @override
  AuthResetPasswordState build() {
    _authRepository = ref.watch(authRepositoryProvider);

    return const AuthResetPasswordState();
  }

  void setVerificationCode(String value) {
    state = state.copyWith(
      verificationCode: value,
      clearVerificationCodeError: true,
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

  void setConfirmNewPassword(String value) {
    state = state.copyWith(
      confirmNewPassword: value,
      clearConfirmNewPasswordError: true,
      clearErrorMessage: true,
    );
  }

  bool validateResetPassword() {
    String? codeError;
    String? newPasswordError;
    String? confirmNewPasswordError;

    if (state.verificationCode.trim().isEmpty) {
      codeError = StringsManager.codeRequired;
    } else if (state.verificationCode.trim().length != 6) {
      codeError = StringsManager.invalidCode;
    }

    if (state.newPassword.isEmpty) {
      newPasswordError = StringsManager.passwordRequired;
    } else if (state.newPassword.length < 6) {
      newPasswordError = StringsManager.passwordMinLength;
    }

    if (state.confirmNewPassword.isEmpty) {
      confirmNewPasswordError = StringsManager.confirmPasswordRequired;
    } else if (state.confirmNewPassword != state.newPassword) {
      confirmNewPasswordError = StringsManager.passwordsDoNotMatch;
    }

    state = state.copyWith(
      verificationCodeError: codeError,
      newPasswordError: newPasswordError,
      confirmNewPasswordError: confirmNewPasswordError,
      clearVerificationCodeError: codeError == null,
      clearNewPasswordError: newPasswordError == null,
      clearConfirmNewPasswordError: confirmNewPasswordError == null,
    );

    return codeError == null && newPasswordError == null && confirmNewPasswordError == null;
  }

  Future<bool> resetPassword() async {
    if (!validateResetPassword()) return false;

    state = state.copyWith(
      status: NotifierStatus.loading,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      await _authRepository.resetPassword(
        code: state.verificationCode.trim(),
        newPassword: state.newPassword,
      );
      state = state.copyWith(
        status: NotifierStatus.success,
        successMessage: StringsManager.passwordResetSuccess,
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
