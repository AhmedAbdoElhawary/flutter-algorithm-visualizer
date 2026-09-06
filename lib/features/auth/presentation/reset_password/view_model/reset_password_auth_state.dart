import 'package:algorithm_visualizer/core/enums/notifier_state.dart';

class AuthResetPasswordState {
  final NotifierStatus status;
  final String? errorMessage;
  final String? successMessage;

  final String verificationCode;
  final String newPassword;
  final String confirmNewPassword;

  final String? verificationCodeError;
  final String? newPasswordError;
  final String? confirmNewPasswordError;

  const AuthResetPasswordState({
    this.status = NotifierStatus.initial,
    this.errorMessage,
    this.successMessage,
    this.verificationCode = '',
    this.newPassword = '',
    this.confirmNewPassword = '',
    this.verificationCodeError,
    this.newPasswordError,
    this.confirmNewPasswordError,
  });

  bool get isLoading => status == NotifierStatus.loading;
  bool get isSuccess => status == NotifierStatus.success;
  bool get isError => status == NotifierStatus.error;

  AuthResetPasswordState copyWith({
    NotifierStatus? status,
    String? errorMessage,
    String? successMessage,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
    String? verificationCode,
    String? newPassword,
    String? confirmNewPassword,
    String? verificationCodeError,
    bool clearVerificationCodeError = false,
    String? newPasswordError,
    bool clearNewPasswordError = false,
    String? confirmNewPasswordError,
    bool clearConfirmNewPasswordError = false,
  }) {
    return AuthResetPasswordState(
      status: status ?? this.status,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
      verificationCode: verificationCode ?? this.verificationCode,
      newPassword: newPassword ?? this.newPassword,
      confirmNewPassword: confirmNewPassword ?? this.confirmNewPassword,
      verificationCodeError:
          clearVerificationCodeError ? null : (verificationCodeError ?? this.verificationCodeError),
      newPasswordError: clearNewPasswordError ? null : (newPasswordError ?? this.newPasswordError),
      confirmNewPasswordError: clearConfirmNewPasswordError
          ? null
          : (confirmNewPasswordError ?? this.confirmNewPasswordError),
    );
  }
}
