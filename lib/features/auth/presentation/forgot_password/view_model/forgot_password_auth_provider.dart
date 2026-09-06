import 'package:algorithm_visualizer/features/auth/presentation/forgot_password/view_model/forgot_password_auth_notifier.dart';
import 'package:algorithm_visualizer/features/auth/presentation/forgot_password/view_model/forgot_password_auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authForgotPasswordProvider =
    NotifierProvider.autoDispose<AuthForgotPasswordNotifier, AuthForgotPasswordState>(() {
  return AuthForgotPasswordNotifier();
});
