import 'package:algorithm_visualizer/core/storage/storage.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/challenge_local_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/unsynced_problems.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/remote/challenge_remote_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

enum ProblemSyncResult {
  success,

  cooldown,

  /// upload did not commit, every mark is kept for the next press
  failure,

  /// the button is hidden for guests
  notSignedIn,
}

/// the only place the problems collection touches firestore
class ProblemSyncService {
  ProblemSyncService({
    required ProblemLocalDataSource localDataSource,
    required UnsyncedProblems unsyncedProblems,
    required ProblemRemoteDataSource remoteDataSource,
    required LocalStorage storage,
  })  : _localDataSource = localDataSource,
        _unsynced = unsyncedProblems,
        _remoteDataSource = remoteDataSource,
        _storage = storage;

  final ProblemLocalDataSource _localDataSource;
  final UnsyncedProblems _unsynced;
  final ProblemRemoteDataSource _remoteDataSource;
  final LocalStorage _storage;

  static const Duration cooldown = Duration(seconds: 30);
  static const String _lastSyncKey = 'last_problems_sync_at';

  static const String _firstDownloadKey = 'problems_first_download_done';

  bool get hasUnsyncedChanges => _unsynced.hasAny;

  DateTime? get _lastSyncAt {
    final millis = lastSync;
    if (millis == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  bool get isFirstDownload => _storage.read<bool>(_firstDownloadKey) == true;

  /// for testing only
  bool? get isFirstDownloadNull => _storage.read<bool>(_firstDownloadKey);

  Future<void> clearFirstDownload() async => await _storage.remove(_firstDownloadKey);
  Future<void> markFirstDownloadDone() async {
    if (isFirstDownload != true) await _storage.write(_firstDownloadKey, true);
  }

  int? get lastSync => _storage.read<int>(_lastSyncKey);
  Future<void> clearLastSync() async => await _storage.remove(_lastSyncKey);
  Future<void> setCurrentSync() async =>
      await _storage.write(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);

  Duration get remainingCooldown {
    final last = _lastSyncAt;
    if (last == null) return Duration.zero;

    final diff = DateTime.now().difference(last);

    if (diff.isNegative) return Duration.zero;

    final remaining = cooldown - diff;
    if (remaining <= Duration.zero) return Duration.zero;

    return Duration(seconds: remaining.inMilliseconds ~/ 1000 + 1);
  }

  Future<void> downloadIfFirstRun() async {
    if (!_remoteDataSource.isSignedIn) return;
    if (isFirstDownload == true) return;

    try {
      await _downloadFromServer();
      await markFirstDownloadDone();
    } catch (e) {
      debugPrint('First problems download failed, will retry next launch: $e');
    }
  }

  Future<ProblemSyncResult> sync() async {
    if (!_remoteDataSource.isSignedIn) return ProblemSyncResult.notSignedIn;
    if (remainingCooldown > Duration.zero) return ProblemSyncResult.cooldown;

    final uploaded = await uploadUnsyncedChanges();
    if (!uploaded) return ProblemSyncResult.failure;

    try {
      await _downloadFromServer();
      await markFirstDownloadDone();
    } catch (e) {
      debugPrint('Sync uploaded but could not download: $e');
    }

    await setCurrentSync();

    return ProblemSyncResult.success;
  }

  Future<bool> uploadUnsyncedChanges() async {
    if (!_remoteDataSource.isSignedIn) return false;

    final needsToBeUploadedIds = _unsynced.needsToBeUploadedIds;
    final needsToBeDeletedIds = _unsynced.needsToBeDeletedIds;

    if (needsToBeUploadedIds.isEmpty && needsToBeDeletedIds.isEmpty) return true;

    final stored = _localDataSource.getProblems();
    final writable = needsToBeUploadedIds
        .map((id) => stored.firstWhereOrNull((problem) => problem.problemId == id))
        .whereType<ProblemStorageDTO>()
        .toList();

    try {
      await _remoteDataSource.batchSaveProblems(writable);
      await _remoteDataSource.batchDeleteProblems(needsToBeDeletedIds);
      await _unsynced.clearUnSync(uploadedSynced: needsToBeUploadedIds, deletedSynced: needsToBeDeletedIds);
      return true;
    } catch (e) {
      debugPrint('Problem sync failed: $e');
      return false;
    }
  }

  Future<void> _downloadFromServer() async {
    final fromServer = await _remoteDataSource.getProblems();

    final byId = <int, ProblemStorageDTO>{
      for (final problem in fromServer)
        if (problem.problemId != null) problem.problemId!: problem,
    };

    final stored = _localDataSource.getProblems();

    for (final id in _unsynced.needsToBeUploadedIds) {
      final local = stored.firstWhereOrNull((problem) => problem.problemId == id);
      if (local != null) byId[id] = local;
    }

    for (final id in _unsynced.needsToBeDeletedIds) {
      byId.remove(id);
    }

    await _localDataSource.overwriteProblems(byId.values.toList());
  }
}
