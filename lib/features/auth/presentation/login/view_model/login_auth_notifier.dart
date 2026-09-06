import 'package:algorithm_visualizer/core/enums/notifier_state.dart';
import 'package:algorithm_visualizer/core/exceptions/error_handler.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/auth/domain/repositories/auth_repository.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/extensions/auth_extensions.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/view_model/auth_providers.dart';
import 'package:algorithm_visualizer/features/auth/presentation/login/view_model/login_auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthLoginNotifier extends Notifier<AuthLoginState> {
  late final AuthRepository _authRepository;

  @override
  AuthLoginState build() {
    _authRepository = ref.watch(authRepositoryProvider);

    return const AuthLoginState();
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

  bool validateLogin() {
    String? emailError;
    String? passwordError;

    if (state.email.trim().isEmpty) {
      emailError = StringsManager.emailRequired;
    } else if (!state.email.validateEmail) {
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

  // Auth Operations
  Future<bool> login() async {
    if (!validateLogin()) return false;

    state = state.copyWith(
      status: NotifierStatus.loading,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      await _authRepository.login(email: state.email.trim(), password: state.password);

      state = state.copyWith(
        status: NotifierStatus.success,
        successMessage: StringsManager.loginSuccess,
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

  Future<void> logout() async {
    await _authRepository.logout();
    state = const AuthLoginState();
  }
}
