class ProblemSyncState {
  const ProblemSyncState({required this.isSyncing, required this.hasPendingChanges});

  const ProblemSyncState.initial() : isSyncing = false, hasPendingChanges = false;

  final bool isSyncing;

  final bool hasPendingChanges;

  ProblemSyncState copyWith({bool? isSyncing, bool? hasPendingChanges}) {
    return ProblemSyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      hasPendingChanges: hasPendingChanges ?? this.hasPendingChanges,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProblemSyncState &&
          isSyncing == other.isSyncing &&
          hasPendingChanges == other.hasPendingChanges;

  @override
  int get hashCode => Object.hash(isSyncing, hasPendingChanges);
}
