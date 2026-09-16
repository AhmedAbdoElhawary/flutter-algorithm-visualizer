import 'package:algorithm_visualizer/core/enums/notifier_state.dart';

class ChangeEmailState {
  final NotifierStatus status;
  final String newEmail;
  final String currentPassword;
  final String? newEmailError;
  final String? currentPasswordError;
  final String? errorMessage;

  const ChangeEmailState({
    this.status = NotifierStatus.initial,
    this.newEmail = '',
    this.currentPassword = '',
    this.newEmailError,
    this.currentPasswordError,
    this.errorMessage,
  });

  bool get isLoading => status == NotifierStatus.loading;
  bool get isSuccess => status == NotifierStatus.success;
  bool get isError => status == NotifierStatus.error;

  ChangeEmailState copyWith({
    NotifierStatus? status,
    String? newEmail,
    String? currentPassword,
    String? newEmailError,
    bool clearNewEmailError = false,
    String? currentPasswordError,
    bool clearCurrentPasswordError = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ChangeEmailState(
      status: status ?? this.status,
      newEmail: newEmail ?? this.newEmail,
      currentPassword: currentPassword ?? this.currentPassword,
      newEmailError: clearNewEmailError ? null : (newEmailError ?? this.newEmailError),
      currentPasswordError:
          clearCurrentPasswordError ? null : (currentPasswordError ?? this.currentPasswordError),
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
