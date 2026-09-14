import 'dart:async';

import 'package:algorithm_visualizer/core/enums/notifier_state.dart';
import 'package:algorithm_visualizer/core/exceptions/error_handler.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/auth/domain/repositories/auth_repository.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/extensions/auth_extensions.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/view_model/auth_providers.dart';
import 'package:algorithm_visualizer/features/auth/presentation/forgot_password/view_model/forgot_password_auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const int _kResendCooldownSeconds = 60;

class AuthForgotPasswordNotifier extends Notifier<AuthForgotPasswordState> {
  late final AuthRepository _authRepository;
  StreamSubscription<int>? _countdownSubscription;

  @override
  AuthForgotPasswordState build() {
    _authRepository = ref.watch(authRepositoryProvider);
    ref.onDispose(() => _countdownSubscription?.cancel());

    return const AuthForgotPasswordState();
  }

  void _startResendCountdown() {
    _countdownSubscription?.cancel();
    state = state.copyWith(resendCountdown: _kResendCooldownSeconds);

    _countdownSubscription = Stream<int>.periodic(
      const Duration(seconds: 1),
      (tick) => _kResendCooldownSeconds - (tick + 1),
    ).take(_kResendCooldownSeconds).listen((remaining) {
      state = state.copyWith(resendCountdown: remaining < 0 ? 0 : remaining);
    });
  }

  void setEmail(String value) {
    state = state.copyWith(
      email: value,
      clearEmailError: true,
      clearErrorMessage: true,
    );
  }

  bool validateForgotPassword() {
    String? emailError;

    if (state.email.trim().isEmpty) {
      emailError = StringsManager.emailRequired;
    } else if (!state.email.validateEmail) {
      emailError = StringsManager.invalidEmail;
    }

    state = state.copyWith(
      emailError: emailError,
      clearEmailError: emailError == null,
    );

    return emailError == null;
  }

  Future<bool> forgotPassword() async {
    if (!validateForgotPassword()) return false;

    state = state.copyWith(
      status: NotifierStatus.loading,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      await _authRepository.forgotPassword(email: state.email.trim());
      state = state.copyWith(
        status: NotifierStatus.success,
        successMessage: StringsManager.resetLinkSent,
      );
      _startResendCountdown();
      return true;
    } catch (e) {
      state = state.copyWith(
        status: NotifierStatus.error,
        errorMessage: ErrorHandler.mapErrorMessage(e),
      );
      return false;
    }
  }

  Future<bool> resendEmail() async {
    if (!state.canResend) return false;

    return forgotPassword();
  }
}
