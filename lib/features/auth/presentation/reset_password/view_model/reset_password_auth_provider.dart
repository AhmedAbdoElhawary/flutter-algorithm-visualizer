import 'package:algorithm_visualizer/features/auth/presentation/reset_password/view_model/reset_password_auth_notifier.dart';
import 'package:algorithm_visualizer/features/auth/presentation/reset_password/view_model/reset_password_auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authResetPasswordProvider =
    NotifierProvider.autoDispose<AuthResetPasswordNotifier, AuthResetPasswordState>(() {
  return AuthResetPasswordNotifier();
});
