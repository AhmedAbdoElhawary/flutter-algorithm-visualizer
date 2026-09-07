import 'package:algorithm_visualizer/core/enums/notifier_state.dart';
import 'package:algorithm_visualizer/core/exceptions/error_handler.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/auth/domain/repositories/auth_repository.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/extensions/auth_extensions.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/view_model/auth_providers.dart';
import 'package:algorithm_visualizer/features/auth/presentation/signup/view_model/signup_auth_state.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthSignUpNotifier extends Notifier<AuthSignUpState> {
  late final AuthRepository _authRepository;

  @override
  AuthSignUpState build() {
    _authRepository = ref.watch(authRepositoryProvider);
    return const AuthSignUpState();
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

  /// Reject the guest placeholder names ("Anonymous", "Anonymous ff 12", …) that
  /// otherwise reach the Home headline as a real display name.
  bool _looksLikePlaceholderName(String name) {
    final n = name.trim().toLowerCase();
    if (n.startsWith('anonymous') || n.startsWith('anon ') || n == 'anon') return true;
    return RegExp(r'^(guest|user|player)[\s_-]*\d*$').hasMatch(n);
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
    } else if (_looksLikePlaceholderName(state.name)) {
      nameError = StringsManager.notValidName;
    }

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

  Future<bool> register() async {
    if (!validateSignUp()) return false;

    state = state.copyWith(
      status: NotifierStatus.loading,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      final user = await _authRepository.register(
        name: state.name.trim(),
        email: state.email.trim(),
        password: state.password,
      );

      /// Carry the guest's work into the account that now owns it. A failure
      /// here is not a sign up failure: the account exists and the user is
      /// signed in, the local copy is kept and retried on the next launch.
      await ref.read(guestDataServiceProvider).migrateToAccount();

      ref.invalidate(problemsProvider);
      ref.invalidate(profileProvider);

      state = state.copyWith(
        status: NotifierStatus.success,
        user: user,
        successMessage: StringsManager.registrationSuccess,
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

}
