import 'package:algorithm_visualizer/core/logging/firebase_logger.dart';
import 'package:algorithm_visualizer/features/challenge/data/data_sources/remote/challenge_remote_data_source.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';

/// Traces every [ProblemRemoteDataSource] call to the console, then hands over
/// to the real data source untouched.
class LoggingProblemRemoteDataSource implements ProblemRemoteDataSource {
  const LoggingProblemRemoteDataSource(this._source);

  final ProblemRemoteDataSource _source;

  static const String _scope = 'firestore';

  @override
  bool get isSignedIn {
    return FirebaseLogger.traceSync(
      _scope,
      'isSignedIn',
      () => _source.isSignedIn,
      describeResult: (signedIn) => '$signedIn',
    );
  }

  @override
  Future<List<ProblemStorageDTO>> getProblems() {
    return FirebaseLogger.trace(
      _scope,
      'getProblems',
      _source.getProblems,
      describeResult: (problems) => 'docs=${problems.length}',
    );
  }

  @override
  Future<void> saveProblem(ProblemStorageDTO problem) {
    /// The wrapped write is deliberately not awaited, it freezes while the
    /// device is offline. Awaiting it here would reintroduce exactly that, so
    /// the call is only announced.
    FirebaseLogger.traceDetached(_scope, 'saveProblem', args: _problemArgs(problem));
    return _source.saveProblem(problem);
  }

  @override
  Future<void> updateProblem(ProblemStorageDTO problem) {
    FirebaseLogger.traceDetached(_scope, 'updateProblem', args: _problemArgs(problem));
    return _source.updateProblem(problem);
  }

  @override
  Future<void> deleteProblem(int problemId) {
    return FirebaseLogger.trace(
      _scope,
      'deleteProblem',
      () => _source.deleteProblem(problemId),
      args: {'problemId': problemId},
    );
  }

  @override
  Future<void> batchSaveProblems(List<ProblemStorageDTO> problems) {
    return FirebaseLogger.trace(
      _scope,
      'batchSaveProblems',
      () => _source.batchSaveProblems(problems),
      args: {'problems': problems.length},
    );
  }

  Map<String, Object?> _problemArgs(ProblemStorageDTO problem) {
    return {
      'problemId': problem.problemId,
      'document': FirebaseLogger.document(problem.toJson()),
    };
  }
}
