import 'package:algorithm_visualizer/core/storage/storage.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/challenge_local_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/problem_pending_local_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/remote/challenge_remote_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/domain/services/problem_sync_service.dart';
import 'package:algorithm_visualizer/features/profile/data/data_sources/local/profile_local_data_source.dart';
import 'package:flutter/foundation.dart';

class GuestDataService {
  GuestDataService({
    required ProblemLocalDataSource problemLocalDataSource,
    required ProblemRemoteDataSource problemRemoteDataSource,
    required ProblemPendingLocalDataSource problemPendingLocalDataSource,
    required ProfileLocalDataSource profileLocalDataSource,
    required LocalStorage storage,
  })  : _problemLocalDataSource = problemLocalDataSource,
        _problemRemoteDataSource = problemRemoteDataSource,
        _problemPendingLocalDataSource = problemPendingLocalDataSource,
        _profileLocalDataSource = profileLocalDataSource,
        _storage = storage;

  final ProblemLocalDataSource _problemLocalDataSource;
  final ProblemRemoteDataSource _problemRemoteDataSource;
  final ProblemPendingLocalDataSource _problemPendingLocalDataSource;
  final ProfileLocalDataSource _profileLocalDataSource;
  final LocalStorage _storage;

  static const String pendingMigrationKey = 'pending_guest_migration';

  bool get hasGuestData => _problemLocalDataSource.getProblems().isNotEmpty || guestName != null;
  String? get guestName => _profileLocalDataSource.getDisplayName();
  bool get hasPendingMigration => _storage.read<bool>(pendingMigrationKey) ?? false;

  Future<bool> migrateToAccount() async {
    final problems = _problemLocalDataSource.getProblems();

    if (problems.isEmpty) {
      await clearGuestData();
      return true;
    }

    try {
      await _problemRemoteDataSource.batchSaveProblems(problems);
      await clearGuestData();
      return true;
    } catch (e) {
      debugPrint('Guest data migration failed, keeping the local copy: $e');
      await _storage.write(pendingMigrationKey, true);
      return false;
    }
  }

  Future<void> clearGuestData() async {
    await Future.wait([
      _problemLocalDataSource.overwriteProblems(const []),
      _problemPendingLocalDataSource.clear(),
      _profileLocalDataSource.clearDisplayName(),
      _storage.remove(pendingMigrationKey),
      _storage.remove(ProblemSyncService.lastSyncKey),
    ]);
  }
}
