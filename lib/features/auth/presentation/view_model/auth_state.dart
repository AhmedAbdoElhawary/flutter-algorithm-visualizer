import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
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

  // Profile Update Fields
  final String currentPassword;
  final String newDisplayName;
  final String newEmail;
  final String newProfilePassword;
  final String confirmNewProfilePassword;

  // Field Level Validation Errors
  final String? nameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? verificationCodeError;
  final String? newPasswordError;
  final String? confirmNewPasswordError;

  // Profile Update Validation Errors
  final String? currentPasswordError;
  final String? newDisplayNameError;
  final String? newEmailError;
  final String? newProfilePasswordError;
  final String? confirmNewProfilePasswordError;

  // Visibility Toggles
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final bool isNewPasswordVisible;
  final bool isConfirmNewPasswordVisible;

  // Profile Update Visibility Toggles
  final bool isCurrentPasswordVisible;
  final bool isNewProfilePasswordVisible;
  final bool isConfirmNewProfilePasswordVisible;

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
    this.currentPassword = '',
    this.newDisplayName = StringsManager.anonymous,
    this.newEmail = '',
    this.newProfilePassword = '',
    this.confirmNewProfilePassword = '',
    this.nameError,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.verificationCodeError,
    this.newPasswordError,
    this.confirmNewPasswordError,
    this.currentPasswordError,
    this.newDisplayNameError,
    this.newEmailError,
    this.newProfilePasswordError,
    this.confirmNewProfilePasswordError,
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.isNewPasswordVisible = false,
    this.isConfirmNewPasswordVisible = false,
    this.isCurrentPasswordVisible = false,
    this.isNewProfilePasswordVisible = false,
    this.isConfirmNewProfilePasswordVisible = false,
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
    String? currentPassword,
    String? newDisplayName,
    String? newEmail,
    String? newProfilePassword,
    String? confirmNewProfilePassword,
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
    String? currentPasswordError,
    bool clearCurrentPasswordError = false,
    String? newDisplayNameError,
    bool clearNewDisplayNameError = false,
    String? newEmailError,
    bool clearNewEmailError = false,
    String? newProfilePasswordError,
    bool clearNewProfilePasswordError = false,
    String? confirmNewProfilePasswordError,
    bool clearConfirmNewProfilePasswordError = false,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
    bool? isNewPasswordVisible,
    bool? isConfirmNewPasswordVisible,
    bool? isCurrentPasswordVisible,
    bool? isNewProfilePasswordVisible,
    bool? isConfirmNewProfilePasswordVisible,
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
      currentPassword: currentPassword ?? this.currentPassword,
      newDisplayName: newDisplayName ?? this.newDisplayName,
      newEmail: newEmail ?? this.newEmail,
      newProfilePassword: newProfilePassword ?? this.newProfilePassword,
      confirmNewProfilePassword: confirmNewProfilePassword ?? this.confirmNewProfilePassword,
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
      currentPasswordError:
          clearCurrentPasswordError ? null : (currentPasswordError ?? this.currentPasswordError),
      newDisplayNameError:
          clearNewDisplayNameError ? null : (newDisplayNameError ?? this.newDisplayNameError),
      newEmailError: clearNewEmailError ? null : (newEmailError ?? this.newEmailError),
      newProfilePasswordError:
          clearNewProfilePasswordError ? null : (newProfilePasswordError ?? this.newProfilePasswordError),
      confirmNewProfilePasswordError:
          clearConfirmNewProfilePasswordError
              ? null
              : (confirmNewProfilePasswordError ?? this.confirmNewProfilePasswordError),
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible: isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      isNewPasswordVisible: isNewPasswordVisible ?? this.isNewPasswordVisible,
      isConfirmNewPasswordVisible:
          isConfirmNewPasswordVisible ?? this.isConfirmNewPasswordVisible,
      isCurrentPasswordVisible:
          isCurrentPasswordVisible ?? this.isCurrentPasswordVisible,
      isNewProfilePasswordVisible:
          isNewProfilePasswordVisible ?? this.isNewProfilePasswordVisible,
      isConfirmNewProfilePasswordVisible:
          isConfirmNewProfilePasswordVisible ?? this.isConfirmNewProfilePasswordVisible,
    );
  }
}
