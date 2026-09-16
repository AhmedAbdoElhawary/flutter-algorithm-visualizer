import 'package:algorithm_visualizer/core/enums/notifier_state.dart';

class ChangePasswordState {
  final NotifierStatus status;
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;
  final String? currentPasswordError;
  final String? newPasswordError;
  final String? confirmPasswordError;
  final String? errorMessage;

  const ChangePasswordState({
    this.status = NotifierStatus.initial,
    this.currentPassword = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.currentPasswordError,
    this.newPasswordError,
    this.confirmPasswordError,
    this.errorMessage,
  });

  bool get isLoading => status == NotifierStatus.loading;
  bool get isSuccess => status == NotifierStatus.success;
  bool get isError => status == NotifierStatus.error;

  ChangePasswordState copyWith({
    NotifierStatus? status,
    String? currentPassword,
    String? newPassword,
    String? confirmPassword,
    String? currentPasswordError,
    bool clearCurrentPasswordError = false,
    String? newPasswordError,
    bool clearNewPasswordError = false,
    String? confirmPasswordError,
    bool clearConfirmPasswordError = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ChangePasswordState(
      status: status ?? this.status,
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      currentPasswordError:
          clearCurrentPasswordError ? null : (currentPasswordError ?? this.currentPasswordError),
      newPasswordError: clearNewPasswordError ? null : (newPasswordError ?? this.newPasswordError),
      confirmPasswordError:
          clearConfirmPasswordError ? null : (confirmPasswordError ?? this.confirmPasswordError),
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
