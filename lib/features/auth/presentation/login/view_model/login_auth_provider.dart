import 'package:algorithm_visualizer/features/auth/presentation/common/view_model/auth_providers.dart';
import 'package:algorithm_visualizer/features/auth/presentation/login/view_model/login_auth_notifier.dart';
import 'package:algorithm_visualizer/features/auth/presentation/login/view_model/login_auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authLoginProvider = NotifierProvider.autoDispose<AuthLoginNotifier, AuthLoginState>(() {
  return AuthLoginNotifier();
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authLocalDataSourceProvider.select((state) => state.isLoggedIn()));
});
