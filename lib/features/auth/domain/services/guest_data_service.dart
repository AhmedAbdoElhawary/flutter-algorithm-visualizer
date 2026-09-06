import 'package:algorithm_visualizer/core/storage/storage.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/challenge_local_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/remote/challenge_remote_data_source.dart';
import 'package:algorithm_visualizer/features/profile/data/data_sources/local/profile_local_data_source.dart';
import 'package:flutter/foundation.dart';

/// Owns the hand over between the local guest session and a Firebase account.
///
/// Both directions are destructive in one way or another, so they live here
/// rather than being spread over the auth notifiers:
/// * signing up carries the guest's work into the new account, then clears it,
/// * logging in throws the guest's work away in favour of the account's data.
class GuestDataService {
  GuestDataService({
    required ProblemLocalDataSource problemLocalDataSource,
    required ProblemRemoteDataSource problemRemoteDataSource,
    required ProfileLocalDataSource profileLocalDataSource,
    required LocalStorage storage,
  })  : _problemLocalDataSource = problemLocalDataSource,
        _problemRemoteDataSource = problemRemoteDataSource,
        _profileLocalDataSource = profileLocalDataSource,
        _storage = storage;

  final ProblemLocalDataSource _problemLocalDataSource;
  final ProblemRemoteDataSource _problemRemoteDataSource;
  final ProfileLocalDataSource _profileLocalDataSource;
  final LocalStorage _storage;

  /// Set when an account was created but its guest data never reached Firestore,
  /// so the upload can be retried the next time the app opens.
  static const String pendingMigrationKey = 'pending_guest_migration';

  /// Whether the guest has anything worth warning them about before it is lost.
  bool get hasGuestData => _problemLocalDataSource.getProblems().isNotEmpty || guestName != null;

  String? get guestName => _profileLocalDataSource.getDisplayName();

  bool get hasPendingMigration => _storage.read<bool>(pendingMigrationKey) ?? false;

  /// Uploads the guest's problems into the account that is signed in now.
  ///
  /// Returns whether the upload went through. On failure the local copy is kept
  /// and [pendingMigrationKey] is raised so the next launch tries again; every
  /// write is an idempotent `set` keyed by problem id, so a retry that overlaps
  /// with writes Firestore had already queued offline is harmless.
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

  /// Wipes every trace of the guest session, leaving a clean slate.
  Future<void> clearGuestData() async {
    await Future.wait([
      _problemLocalDataSource.overwriteProblems(const []),
      _profileLocalDataSource.clearDisplayName(),
      _storage.remove(pendingMigrationKey),
    ]);
  }
}
