import 'package:algorithm_visualizer/core/enums/notifier_state.dart';

class AuthForgotPasswordState {
  final NotifierStatus status;
  final String? errorMessage;
  final String? successMessage;

  final String email;

  final String? emailError;

  const AuthForgotPasswordState({
    this.status = NotifierStatus.initial,
    this.errorMessage,
    this.successMessage,
    this.email = '',
    this.emailError,
  });

  bool get isLoading => status == NotifierStatus.loading;
  bool get isSuccess => status == NotifierStatus.success;
  bool get isError => status == NotifierStatus.error;

  AuthForgotPasswordState copyWith({
    NotifierStatus? status,
    String? errorMessage,
    String? successMessage,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
    String? email,
    String? emailError,
    bool clearEmailError = false,
  }) {
    return AuthForgotPasswordState(
      status: status ?? this.status,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
      email: email ?? this.email,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
    );
  }
}
