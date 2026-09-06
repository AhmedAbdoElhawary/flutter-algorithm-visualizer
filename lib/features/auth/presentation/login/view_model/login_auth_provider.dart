import 'package:algorithm_visualizer/features/auth/presentation/login/view_model/login_auth_notifier.dart';
import 'package:algorithm_visualizer/features/auth/presentation/login/view_model/login_auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authLoginProvider = NotifierProvider.autoDispose<AuthLoginNotifier, AuthLoginState>(() {
  return AuthLoginNotifier();
});
