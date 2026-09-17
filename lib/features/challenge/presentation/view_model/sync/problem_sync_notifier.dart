import 'package:algorithm_visualizer/features/challenge/domain/services/problem_sync_service.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/sync/problem_sync_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProblemSyncNotifier extends Notifier<ProblemSyncState> {
  ProblemSyncService get _service => ref.read(problemSyncServiceProvider);

  @override
  ProblemSyncState build() {
    return ProblemSyncState(isSyncing: false, hasPendingChanges: _service.hasPendingChanges);
  }

  Duration get remainingCooldown => _service.remainingCooldown;

  void refreshPendingFlag() {
    state = state.copyWith(hasPendingChanges: _service.hasPendingChanges);
  }

  Future<ProblemSyncResult> sync() async {
    if (state.isSyncing) return ProblemSyncResult.failure;

    state = state.copyWith(isSyncing: true);

    try {
      final result = await _service.sync();

      if (result == ProblemSyncResult.success) {
        await ref.read(problemsProvider.notifier).reload(forceRemote: true);
      }

      return result;
    } finally {
      state = ProblemSyncState(isSyncing: false, hasPendingChanges: _service.hasPendingChanges);
    }
  }
}
