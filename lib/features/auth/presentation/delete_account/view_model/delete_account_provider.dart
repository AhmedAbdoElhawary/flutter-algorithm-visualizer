import 'package:algorithm_visualizer/features/auth/presentation/delete_account/view_model/delete_account_notifier.dart';
import 'package:algorithm_visualizer/features/auth/presentation/delete_account/view_model/delete_account_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deleteAccountProvider = NotifierProvider.autoDispose<DeleteAccountNotifier, DeleteAccountState>(() {
  return DeleteAccountNotifier();
});
