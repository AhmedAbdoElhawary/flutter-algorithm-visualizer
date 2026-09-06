import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/auth/domain/repositories/auth_repository.dart';
import 'package:algorithm_visualizer/features/auth/presentation/view_model/auth_providers.dart';
import 'package:algorithm_visualizer/features/auth/presentation/view_model/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _authRepository;

  @override
  AuthState build() {
    _authRepository = ref.watch(authRepositoryProvider);

    _loadInitialUser();
    return const AuthState();
  }

  void _loadInitialUser() {
    try {
      final user = _authRepository.getCurrentUser();
      if (user != null) state = state.copyWith(user: user);
    } catch (_) {}
  }

  // Field updates
  void setName(String value) {
    state = state.copyWith(
      name: value,
      clearNameError: true,
      clearErrorMessage: true,
    );
  }

  void setEmail(String value) {
    state = state.copyWith(
      email: value,
      clearEmailError: true,
      clearErrorMessage: true,
    );
  }

  void setPassword(String value) {
    state = state.copyWith(
      password: value,
      clearPasswordError: true,
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

  // Visibility toggles
  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(isConfirmPasswordVisible: !state.isConfirmPasswordVisible);
  }

  void toggleNewPasswordVisibility() {
    state = state.copyWith(isNewPasswordVisible: !state.isNewPasswordVisible);
  }

  void toggleConfirmNewPasswordVisibility() {
    state = state.copyWith(isConfirmNewPasswordVisible: !state.isConfirmNewPasswordVisible);
  }

  // Profile Update Field updates
  void setCurrentPassword(String value) {
    state = state.copyWith(
      currentPassword: value,
      clearCurrentPasswordError: true,
      clearErrorMessage: true,
    );
  }

  void setNewDisplayName(String value) {
    state = state.copyWith(
      newDisplayName: value,
      clearNewDisplayNameError: true,
      clearErrorMessage: true,
    );
  }

  void setNewEmail(String value) {
    state = state.copyWith(
      newEmail: value,
      clearNewEmailError: true,
      clearErrorMessage: true,
    );
  }

  void setNewProfilePassword(String value) {
    state = state.copyWith(
      newProfilePassword: value,
      clearNewProfilePasswordError: true,
      clearErrorMessage: true,
    );
  }

  void setConfirmNewProfilePassword(String value) {
    state = state.copyWith(
      confirmNewProfilePassword: value,
      clearConfirmNewProfilePasswordError: true,
      clearErrorMessage: true,
    );
  }

  // Profile Update Visibility toggles
  void toggleCurrentPasswordVisibility() {
    state = state.copyWith(isCurrentPasswordVisible: !state.isCurrentPasswordVisible);
  }

  void toggleNewProfilePasswordVisibility() {
    state = state.copyWith(isNewProfilePasswordVisible: !state.isNewProfilePasswordVisible);
  }

  void toggleConfirmNewProfilePasswordVisibility() {
    state = state.copyWith(
      isConfirmNewProfilePasswordVisible: !state.isConfirmNewProfilePasswordVisible,
    );
  }

  // Validations
  bool validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }

  bool validateLogin() {
    String? emailError;
    String? passwordError;

    if (state.email.trim().isEmpty) {
      emailError = StringsManager.emailRequired;
    } else if (!validateEmail(state.email)) {
      emailError = StringsManager.invalidEmail;
    }

    if (state.password.isEmpty) {
      passwordError = StringsManager.passwordRequired;
    } else if (state.password.length < 6) {
      passwordError = StringsManager.passwordMinLength;
    }

    state = state.copyWith(
      emailError: emailError,
      passwordError: passwordError,
      clearEmailError: emailError == null,
      clearPasswordError: passwordError == null,
    );

    return emailError == null && passwordError == null;
  }

  bool validateSignUp() {
    String? nameError;
    String? emailError;
    String? passwordError;
    String? confirmPasswordError;

    if (state.name.trim().isEmpty) {
      nameError = StringsManager.nameRequired;
    } else if (state.name.trim().length < 2) {
      nameError = StringsManager.nameMinLength;
    }

    if (state.email.trim().isEmpty) {
      emailError = StringsManager.emailRequired;
    } else if (!validateEmail(state.email)) {
      emailError = StringsManager.invalidEmail;
    }

    if (state.password.isEmpty) {
      passwordError = StringsManager.passwordRequired;
    } else if (state.password.length < 6) {
      passwordError = StringsManager.passwordMinLength;
    }

    if (state.confirmPassword.isEmpty) {
      confirmPasswordError = StringsManager.confirmPasswordRequired;
    } else if (state.confirmPassword != state.password) {
      confirmPasswordError = StringsManager.passwordsDoNotMatch;
    }

    state = state.copyWith(
      nameError: nameError,
      emailError: emailError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      clearNameError: nameError == null,
      clearEmailError: emailError == null,
      clearPasswordError: passwordError == null,
      clearConfirmPasswordError: confirmPasswordError == null,
    );

    return nameError == null && emailError == null && passwordError == null && confirmPasswordError == null;
  }

  bool validateForgotPassword() {
    String? emailError;

    if (state.email.trim().isEmpty) {
      emailError = StringsManager.emailRequired;
    } else if (!validateEmail(state.email)) {
      emailError = StringsManager.invalidEmail;
    }

    state = state.copyWith(
      emailError: emailError,
      clearEmailError: emailError == null,
    );

    return emailError == null;
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

  // Profile Update Validations
  bool validateUpdateDisplayName({required String name}) {
    String? newDisplayNameError;

    if (name.trim().isEmpty) {
      newDisplayNameError = StringsManager.newDisplayNameRequired;
    } else if (name.trim().length < 2) {
      newDisplayNameError = StringsManager.nameMinLength;
    }



    state = state.copyWith(
      newDisplayNameError: newDisplayNameError,
      clearNewDisplayNameError: newDisplayNameError == null,
    );

    return newDisplayNameError == null;
  }

  bool validateUpdateEmail() {
    String? newEmailError;
    String? currentPasswordError;

    if (state.newEmail.trim().isEmpty) {
      newEmailError = StringsManager.newEmailRequired;
    } else if (!validateEmail(state.newEmail)) {
      newEmailError = StringsManager.invalidEmail;
    }

    if (state.currentPassword.isEmpty) {
      currentPasswordError = StringsManager.currentPasswordRequired;
    }

    state = state.copyWith(
      newEmailError: newEmailError,
      currentPasswordError: currentPasswordError,
      clearNewEmailError: newEmailError == null,
      clearCurrentPasswordError: currentPasswordError == null,
    );

    return newEmailError == null && currentPasswordError == null;
  }

  bool validateUpdatePassword() {
    String? currentPasswordError;
    String? newProfilePasswordError;
    String? confirmNewProfilePasswordError;

    if (state.currentPassword.isEmpty) {
      currentPasswordError = StringsManager.currentPasswordRequired;
    }

    if (state.newProfilePassword.isEmpty) {
      newProfilePasswordError = StringsManager.newPasswordRequired;
    } else if (state.newProfilePassword.length < 6) {
      newProfilePasswordError = StringsManager.passwordMinLength;
    }

    if (state.confirmNewProfilePassword.isEmpty) {
      confirmNewProfilePasswordError = StringsManager.confirmPasswordRequired;
    } else if (state.confirmNewProfilePassword != state.newProfilePassword) {
      confirmNewProfilePasswordError = StringsManager.passwordsDoNotMatch;
    }

    state = state.copyWith(
      currentPasswordError: currentPasswordError,
      newProfilePasswordError: newProfilePasswordError,
      confirmNewProfilePasswordError: confirmNewProfilePasswordError,
      clearCurrentPasswordError: currentPasswordError == null,
      clearNewProfilePasswordError: newProfilePasswordError == null,
      clearConfirmNewProfilePasswordError: confirmNewProfilePasswordError == null,
    );

    return currentPasswordError == null &&
        newProfilePasswordError == null &&
        confirmNewProfilePasswordError == null;
  }

  // Auth Operations
  Future<bool> login() async {
    if (!validateLogin()) return false;

    state = state.copyWith(
      status: AuthStatus.loading,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      final user = await _authRepository.login(
        email: state.email.trim(),
        password: state.password,
      );

      // // Also update Profile storage username for consistency
      // ref.read(profileStorageProvider.notifier).updateName(user.name);

      state = state.copyWith(
        status: AuthStatus.success,
        user: user,
        successMessage: StringsManager.loginSuccess,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _mapErrorMessage(e),
      );
      return false;
    }
  }

  Future<bool> register() async {
    if (!validateSignUp()) return false;

    state = state.copyWith(
      status: AuthStatus.loading,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      final user = await _authRepository.register(
        name: state.name.trim(),
        email: state.email.trim(),
        password: state.password,
      );

      // // Update Profile storage username
      // ref.read(profileStorageProvider.notifier).updateName(user.name);

      state = state.copyWith(
        status: AuthStatus.success,
        user: user,
        successMessage: StringsManager.registrationSuccess,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _mapErrorMessage(e),
      );
      return false;
    }
  }

  Future<bool> forgotPassword() async {
    if (!validateForgotPassword()) return false;

    state = state.copyWith(
      status: AuthStatus.loading,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      await _authRepository.forgotPassword(email: state.email.trim());
      state = state.copyWith(
        status: AuthStatus.success,
        successMessage: StringsManager.resetLinkSent,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _mapErrorMessage(e),
      );
      return false;
    }
  }

  Future<bool> resetPassword() async {
    if (!validateResetPassword()) return false;

    state = state.copyWith(
      status: AuthStatus.loading,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      await _authRepository.resetPassword(
        code: state.verificationCode.trim(),
        newPassword: state.newPassword,
      );
      state = state.copyWith(
        status: AuthStatus.success,
        successMessage: StringsManager.passwordResetSuccess,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _mapErrorMessage(e),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = const AuthState();
  }

  // Profile Update Operations
  Future<bool> updateDisplayName({required String name}) async {
    if (!validateUpdateDisplayName(name: name)) return false;

    state = state.copyWith(
      status: AuthStatus.loading,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      await _authRepository.updateDisplayName(displayName: name.trim());

      // Update AuthUser in state
      if (state.user != null) state = state.copyWith(user: state.user?.copyWith(name: name.trim()));

      // // Sync profile storage
      // ref.read(profileStorageProvider.notifier).updateName(name.trim());

      state = state.copyWith(
        status: AuthStatus.success,
        successMessage: StringsManager.displayNameUpdated,
        newDisplayName: name,
        clearNewDisplayNameError: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _mapErrorMessage(e),
      );
      return false;
    }
  }

  Future<bool> updateEmail() async {
    if (!validateUpdateEmail()) return false;

    state = state.copyWith(
      status: AuthStatus.loading,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      await _authRepository.updateEmail(
        newEmail: state.newEmail.trim(),
        currentPassword: state.currentPassword,
      );

      // Update AuthUser in state
      if (state.user != null) {
        state = state.copyWith(user: state.user!.copyWith(email: state.newEmail.trim()));
      }

      state = state.copyWith(
        status: AuthStatus.success,
        successMessage: StringsManager.emailUpdated,
        currentPassword: '',
        newEmail: '',
        clearCurrentPasswordError: true,
        clearNewEmailError: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _mapErrorMessage(e),
      );
      return false;
    }
  }

  Future<bool> updatePassword() async {
    if (!validateUpdatePassword()) return false;

    state = state.copyWith(
      status: AuthStatus.loading,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      await _authRepository.updatePassword(
        currentPassword: state.currentPassword,
        newPassword: state.newProfilePassword,
      );

      state = state.copyWith(
        status: AuthStatus.success,
        successMessage: StringsManager.passwordUpdated,
        currentPassword: '',
        newProfilePassword: '',
        confirmNewProfilePassword: '',
        clearCurrentPasswordError: true,
        clearNewProfilePasswordError: true,
        clearConfirmNewProfilePasswordError: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _mapErrorMessage(e),
      );
      return false;
    }
  }

  void resetProfileUpdateForm() {
    state = state.copyWith(
      currentPassword: '',
      newDisplayName: '',
      newEmail: '',
      newProfilePassword: '',
      confirmNewProfilePassword: '',
      clearCurrentPasswordError: true,
      clearNewDisplayNameError: true,
      clearNewEmailError: true,
      clearNewProfilePasswordError: true,
      clearConfirmNewProfilePasswordError: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  void resetForm() {
    state = state.copyWith(
      status: AuthStatus.initial,
      clearErrorMessage: true,
      clearSuccessMessage: true,
      name: '',
      email: '',
      password: '',
      confirmPassword: '',
      verificationCode: '',
      newPassword: '',
      confirmNewPassword: '',
      currentPassword: '',
      newDisplayName: '',
      newEmail: '',
      newProfilePassword: '',
      confirmNewProfilePassword: '',
      clearNameError: true,
      clearEmailError: true,
      clearPasswordError: true,
      clearConfirmPasswordError: true,
      clearVerificationCodeError: true,
      clearNewPasswordError: true,
      clearConfirmNewPasswordError: true,
      clearCurrentPasswordError: true,
      clearNewDisplayNameError: true,
      clearNewEmailError: true,
      clearNewProfilePasswordError: true,
      clearConfirmNewProfilePasswordError: true,
    );
  }

  String _mapErrorMessage(dynamic error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('invalid email or password') || msg.contains('invalid credentials')) {
      return StringsManager.invalidCredentials;
    }
    if (msg.contains('already exists')) {
      return StringsManager.userAlreadyExists;
    }
    if (msg.contains('no account found') || msg.contains('not found')) {
      return StringsManager.userNotFound;
    }
    if (msg.contains('verification code')) {
      return StringsManager.invalidCode;
    }
    if (msg.contains('network') || msg.contains('socket') || msg.contains('timeout')) {
      return StringsManager.networkError;
    }
    if (msg.contains('log in again') || msg.contains('requires-recent-login')) {
      return StringsManager.reauthenticateRequired;
    }
    return StringsManager.sorryForInconvenience;
  }
}
