import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';

enum AuthStatus { initial, loading, success, error }

enum AuthScreenType { login, signUp, forgotPassword, resetPassword }

class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final String? errorMessage;
  final String? successMessage;

  // Form Field Values
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final String verificationCode;
  final String newPassword;
  final String confirmNewPassword;

  // Field Level Validation Errors
  final String? nameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? verificationCodeError;
  final String? newPasswordError;
  final String? confirmNewPasswordError;

  // Visibility Toggles
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final bool isNewPasswordVisible;
  final bool isConfirmNewPasswordVisible;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.successMessage,
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.verificationCode = '',
    this.newPassword = '',
    this.confirmNewPassword = '',
    this.nameError,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.verificationCodeError,
    this.newPasswordError,
    this.confirmNewPasswordError,
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.isNewPasswordVisible = false,
    this.isConfirmNewPasswordVisible = false,
  });

  bool get isLoading => status == AuthStatus.loading;
  bool get isSuccess => status == AuthStatus.success;
  bool get isError => status == AuthStatus.error;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? errorMessage,
    String? successMessage,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    String? verificationCode,
    String? newPassword,
    String? confirmNewPassword,
    String? nameError,
    bool clearNameError = false,
    String? emailError,
    bool clearEmailError = false,
    String? passwordError,
    bool clearPasswordError = false,
    String? confirmPasswordError,
    bool clearConfirmPasswordError = false,
    String? verificationCodeError,
    bool clearVerificationCodeError = false,
    String? newPasswordError,
    bool clearNewPasswordError = false,
    String? confirmNewPasswordError,
    bool clearConfirmNewPasswordError = false,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
    bool? isNewPasswordVisible,
    bool? isConfirmNewPasswordVisible,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      verificationCode: verificationCode ?? this.verificationCode,
      newPassword: newPassword ?? this.newPassword,
      confirmNewPassword: confirmNewPassword ?? this.confirmNewPassword,
      nameError: clearNameError ? null : (nameError ?? this.nameError),
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      passwordError: clearPasswordError ? null : (passwordError ?? this.passwordError),
      confirmPasswordError:
          clearConfirmPasswordError ? null : (confirmPasswordError ?? this.confirmPasswordError),
      verificationCodeError:
          clearVerificationCodeError ? null : (verificationCodeError ?? this.verificationCodeError),
      newPasswordError: clearNewPasswordError ? null : (newPasswordError ?? this.newPasswordError),
      confirmNewPasswordError:
          clearConfirmNewPasswordError ? null : (confirmNewPasswordError ?? this.confirmNewPasswordError),
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible: isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      isNewPasswordVisible: isNewPasswordVisible ?? this.isNewPasswordVisible,
      isConfirmNewPasswordVisible: isConfirmNewPasswordVisible ?? this.isConfirmNewPasswordVisible,
    );
  }
}
