import 'package:algorithm_visualizer/core/storage/storage.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/problem_pending_local_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/remote/challenge_remote_data_source.dart';
import 'package:flutter/foundation.dart';

enum ProblemSyncResult {
  success,
  cooldown,
  failure,
  notSignedIn,
}

class ProblemSyncService {
  ProblemSyncService({
    required ProblemPendingLocalDataSource pendingDataSource,
    required ProblemRemoteDataSource remoteDataSource,
    required LocalStorage storage,
  })  : _pendingDataSource = pendingDataSource,
        _remoteDataSource = remoteDataSource,
        _storage = storage;

  final ProblemPendingLocalDataSource _pendingDataSource;
  final ProblemRemoteDataSource _remoteDataSource;
  final LocalStorage _storage;

  static const Duration cooldown = Duration(seconds: 30);

  static const String lastSyncKey = 'last_problems_sync_at';

  bool get hasPendingChanges => _pendingDataSource.hasPendingChanges;

  DateTime? get lastSyncAt {
    final millis = _storage.read<int>(lastSyncKey);
    if (millis == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Duration get remainingCooldown {
    final last = lastSyncAt;
    if (last == null) return Duration.zero;

    final elapsed = DateTime.now().difference(last);

    if (elapsed.isNegative) return Duration.zero;

    final remaining = cooldown - elapsed;
    if (remaining <= Duration.zero) return Duration.zero;

    return Duration(seconds: remaining.inMilliseconds ~/ 1000 + 1);
  }

  Future<ProblemSyncResult> sync() async {
    if (!_remoteDataSource.isSignedIn) return ProblemSyncResult.notSignedIn;
    if (remainingCooldown > Duration.zero) return ProblemSyncResult.cooldown;

    final pushed = await pushPendingChanges();
    if (!pushed) return ProblemSyncResult.failure;

    await _storage.write(lastSyncKey, DateTime.now().millisecondsSinceEpoch);

    return ProblemSyncResult.success;
  }

  Future<bool> pushPendingChanges() async {
    if (!_remoteDataSource.isSignedIn) return false;

    final pending = _pendingDataSource.getPending();
    final deletedIds = _pendingDataSource.getDeletedIds();

    if (pending.isEmpty && deletedIds.isEmpty) return true;

    try {
      await _remoteDataSource.batchSaveProblems(pending);
      await _remoteDataSource.batchDeleteProblems(deletedIds);
      await _pendingDataSource.clear();
      return true;
    } catch (e) {
      debugPrint('Problem sync failed, keeping the pending queue: $e');
      return false;
    }
  }
}
