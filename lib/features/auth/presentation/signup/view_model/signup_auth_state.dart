import 'package:algorithm_visualizer/core/enums/notifier_state.dart';
import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';

class AuthSignUpState {
  final NotifierStatus status;
  final AuthUser? user;
  final String? errorMessage;
  final String? successMessage;

  // Form Field Values
  final String name;
  final String email;
  final String password;
  final String confirmPassword;

  // Field Level Validation Errors
  final String? nameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;

  const AuthSignUpState({
    this.status = NotifierStatus.initial,
    this.user,
    this.errorMessage,
    this.successMessage,
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.nameError,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
  });

  bool get isLoading => status == NotifierStatus.loading;
  bool get isSuccess => status == NotifierStatus.success;
  bool get isError => status == NotifierStatus.error;

  AuthSignUpState copyWith({
    NotifierStatus? status,
    AuthUser? user,
    String? errorMessage,
    String? successMessage,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    String? nameError,
    bool clearNameError = false,
    String? emailError,
    bool clearEmailError = false,
    String? passwordError,
    bool clearPasswordError = false,
    String? confirmPasswordError,
    bool clearConfirmPasswordError = false,
  }) {
    return AuthSignUpState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      nameError: clearNameError ? null : (nameError ?? this.nameError),
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      passwordError: clearPasswordError ? null : (passwordError ?? this.passwordError),
      confirmPasswordError:
          clearConfirmPasswordError ? null : (confirmPasswordError ?? this.confirmPasswordError),
    );
  }
}
