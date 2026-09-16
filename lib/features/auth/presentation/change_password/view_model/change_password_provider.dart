import 'package:algorithm_visualizer/features/auth/presentation/change_password/view_model/change_password_notifier.dart';
import 'package:algorithm_visualizer/features/auth/presentation/change_password/view_model/change_password_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final changePasswordProvider = NotifierProvider.autoDispose<ChangePasswordNotifier, ChangePasswordState>(() {
  return ChangePasswordNotifier();
});
