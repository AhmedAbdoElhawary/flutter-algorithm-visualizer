import 'package:algorithm_visualizer/features/challenge/presentation/view_model/sync/problem_sync_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts idle with nothing to sync', () {
    const state = ProblemSyncState.initial();

    expect(state.isSyncing, isFalse);
    expect(state.hasUnsyncedChanges, isFalse);
  });

  test('copyWith changes only what it is given', () {
    const state = ProblemSyncState.initial();

    expect(state.copyWith(isSyncing: true), const ProblemSyncState(isSyncing: true, hasUnsyncedChanges: false));
    expect(
      state.copyWith(hasUnsyncedChanges: true),
      const ProblemSyncState(isSyncing: false, hasUnsyncedChanges: true),
    );
    expect(state.copyWith(), state);
  });

  test('equal fields are equal with the same hash', () {
    const a = ProblemSyncState(isSyncing: true, hasUnsyncedChanges: true);
    const b = ProblemSyncState(isSyncing: true, hasUnsyncedChanges: true);

    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(const ProblemSyncState.initial()));
  });
}
