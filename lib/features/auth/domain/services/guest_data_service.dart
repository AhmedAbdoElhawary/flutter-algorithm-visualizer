import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/challenge_local_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/unsynced_problems.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/remote/challenge_remote_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/domain/services/problem_sync_service.dart';
import 'package:algorithm_visualizer/features/profile/data/data_sources/local/profile_local_data_source.dart';

class GuestDataService {
  GuestDataService({
    required ProblemLocalDataSource problemLocalDataSource,
    required ProblemRemoteDataSource problemRemoteDataSource,
    required UnsyncedProblems unsyncedProblems,
    required ProblemSyncService problemSyncService,
    required ProfileLocalDataSource profileLocalDataSource,
  })  : _problemLocalDataSource = problemLocalDataSource,
        _problemRemoteDataSource = problemRemoteDataSource,
        _unsyncedProblems = unsyncedProblems,
        _problemSyncService = problemSyncService,
        _profileLocalDataSource = profileLocalDataSource;

  final ProblemLocalDataSource _problemLocalDataSource;
  final ProblemRemoteDataSource _problemRemoteDataSource;
  final UnsyncedProblems _unsyncedProblems;
  final ProblemSyncService _problemSyncService;
  final ProfileLocalDataSource _profileLocalDataSource;

  bool get hasGuestData {
    /// it's not guest anymore
    if (_problemRemoteDataSource.isSignedIn) return false;

    return _problemLocalDataSource.getProblems().isNotEmpty || guestName != null;
  }

  String? get guestName => _profileLocalDataSource.getDisplayName();

  Future<bool> mergeGuestDataToTheAccount() async {
    await _profileLocalDataSource.clearDisplayName();

    final problems = _problemLocalDataSource.getProblems();
    final problemIds = problems.map((problem) => problem.problemId).whereType<int>();

    if (problemIds.isEmpty) {
      await _problemSyncService.clearFirstDownload();
      await _problemSyncService.downloadIfFirstRun();
      return true;
    }

    await _unsyncedProblems.severalNeedsToBeUploaded(problemIds);

    final uploaded = await _problemSyncService.uploadUnsyncedChanges();

    if (uploaded) await _problemSyncService.markFirstDownloadDone();

    return uploaded;
  }

  Future<void> clearGuestData() async {
    await Future.wait([
      _problemLocalDataSource.overwriteProblems(const []),
      _unsyncedProblems.clear(),
      _profileLocalDataSource.clearDisplayName(),
      _problemSyncService.clearLastSync(),
      _problemSyncService.clearFirstDownload(),
    ]);
  }
}
