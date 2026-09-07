import 'package:algorithm_visualizer/core/enums/notifier_state.dart';
import 'package:algorithm_visualizer/core/exceptions/error_handler.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/auth/domain/repositories/auth_repository.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/extensions/auth_extensions.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/view_model/auth_providers.dart';
import 'package:algorithm_visualizer/features/auth/presentation/login/view_model/login_auth_state.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
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

      /// The account's own data replaces the guest session entirely, the user
      /// has already confirmed losing it on the login page.
      await ref.read(guestDataServiceProvider).clearGuestData();
      _reloadUserScopedData();

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
    /// Signing out tears down the profile screen that keeps this auto-dispose
    /// notifier alive, so pin it until the cleanup below finishes; otherwise
    /// `ref` is disposed mid-flight and every use after the first await throws.
    final keepAlive = ref.keepAlive();

    try {
      await _authRepository.logout();

      /// Start the next session as a clean guest rather than leaving anything of
      /// the signed out account behind.
      await ref.read(guestDataServiceProvider).clearGuestData();
      _reloadUserScopedData();
    } finally {
      keepAlive.close();
    }
  }

  /// Drops everything keyed to "who is signed in" so it is read again from
  /// whichever store now owns it.
  void _reloadUserScopedData() {
    ref.invalidate(problemsProvider);
    ref.invalidate(profileProvider);
  }
}
