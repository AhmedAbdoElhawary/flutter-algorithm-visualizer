import 'package:algorithm_visualizer/features/auth/presentation/signup/view_model/signup_auth_notifier.dart';
import 'package:algorithm_visualizer/features/auth/presentation/signup/view_model/signup_auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authSignupProvider = NotifierProvider<AuthSignUpNotifier, AuthSignUpState>(() {
  return AuthSignUpNotifier();
});
