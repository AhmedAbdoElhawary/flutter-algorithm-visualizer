class ProblemSyncState {
  const ProblemSyncState({required this.isSyncing, required this.hasUnsyncedChanges});

  const ProblemSyncState.initial()
      : isSyncing = false,
        hasUnsyncedChanges = false;

  final bool isSyncing;

  final bool hasUnsyncedChanges;

  ProblemSyncState copyWith({bool? isSyncing, bool? hasUnsyncedChanges}) {
    return ProblemSyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      hasUnsyncedChanges: hasUnsyncedChanges ?? this.hasUnsyncedChanges,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProblemSyncState &&
          isSyncing == other.isSyncing &&
          hasUnsyncedChanges == other.hasUnsyncedChanges;

  @override
  int get hashCode => Object.hash(isSyncing, hasUnsyncedChanges);
}
