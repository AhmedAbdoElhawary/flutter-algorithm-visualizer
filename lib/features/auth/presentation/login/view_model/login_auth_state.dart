import 'package:algorithm_visualizer/core/enums/notifier_state.dart';

class AuthLoginState {
  final NotifierStatus status;
  final String? errorMessage;
  final String? successMessage;

  final String email;
  final String password;

  final String? emailError;
  final String? passwordError;

  const AuthLoginState({
    this.status = NotifierStatus.initial,
    this.errorMessage,
    this.successMessage,
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
  });

  bool get isLoading => status == NotifierStatus.loading;
  bool get isSuccess => status == NotifierStatus.success;
  bool get isError => status == NotifierStatus.error;

  AuthLoginState copyWith({
    NotifierStatus? status,
    String? errorMessage,
    String? successMessage,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
    String? email,
    String? password,
    String? emailError,
    bool clearEmailError = false,
    String? passwordError,
    bool clearPasswordError = false,
  }) {
    return AuthLoginState(
      status: status ?? this.status,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      passwordError: clearPasswordError ? null : (passwordError ?? this.passwordError),
    );
  }
}
