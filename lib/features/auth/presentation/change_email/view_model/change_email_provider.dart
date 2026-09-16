import 'package:algorithm_visualizer/features/auth/presentation/change_email/view_model/change_email_notifier.dart';
import 'package:algorithm_visualizer/features/auth/presentation/change_email/view_model/change_email_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final changeEmailProvider = NotifierProvider.autoDispose<ChangeEmailNotifier, ChangeEmailState>(() {
  return ChangeEmailNotifier();
});
