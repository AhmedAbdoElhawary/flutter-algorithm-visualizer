import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Persists the per-user problem progress ([ProblemStorageDTO]) in Firestore so
/// it follows the signed-in account across devices.
///
/// Layout: `users/{uid}/problems/{problemId}` where each document is the JSON of
/// a [ProblemStorageDTO]. Kept intentionally simple for now; edge cases (merge
/// conflicts, offline queueing, etc.) are handled elsewhere later.
abstract class ProblemRemoteDataSource {
  bool get isSignedIn;

  Future<List<ProblemStorageDTO>> getProblems();

  Future<void> saveProblem(ProblemStorageDTO problem);

  Future<void> updateProblem(ProblemStorageDTO problem);

  Future<void> deleteProblem(int problemId);

  /// Uploads a whole guest session in one go, used right after sign up.
  ///
  /// Unlike [saveProblem] this awaits the commit, because the caller has to know
  /// whether the hand over succeeded before it erases the local copy.
  Future<void> batchSaveProblems(List<ProblemStorageDTO> problems);
}

class ProblemRemoteDataSourceImpl implements ProblemRemoteDataSource {
  ProblemRemoteDataSourceImpl();

  late final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Firestore rejects a batch above 500 writes, a little head room is kept.
  static const int _batchSizeLimit = 450;

  /// A commit never completes while the device is offline, it only resolves once
  /// the server acknowledges it. Migration has to fail fast instead of hanging
  /// the sign up flow, the queued writes still reach Firestore on reconnect.
  static const Duration _commitTimeout = Duration(seconds: 15);

  @override
  bool get isSignedIn {
    try {
      return _auth.currentUser != null;
    } catch (_) {
      /// Firebase never came up, `main` swallows that failure. Falling back to
      /// a guest keeps the app usable on local storage alone.
      return false;
    }
  }

  CollectionReference<Map<String, dynamic>>? _problemsRef() {
    if (!isSignedIn) return null;
    return _firestore.collection('users').doc(_auth.currentUser!.uid).collection('problems');
  }

  @override
  Future<List<ProblemStorageDTO>> getProblems() async {
    final ref = _problemsRef();
    if (ref == null) return [];

    final snapshot = await ref.get();
    return snapshot.docs.map((doc) => ProblemStorageDTO.fromJson(doc.data())).toList();
  }

  @override
  Future<void> saveProblem(ProblemStorageDTO problem) async {
    final ref = _problemsRef();
    if (ref == null || problem.problemId == null) return;

    /// todo: look to this again:
    /// it's freezed while the device offline when write await
    ref.doc(problem.problemId.toString()).set(problem.toJson());
  }

  @override
  Future<void> updateProblem(ProblemStorageDTO problem) => saveProblem(problem);

  @override
  Future<void> deleteProblem(int problemId) async {
    final ref = _problemsRef();
    if (ref == null) return;

    return await ref.doc(problemId.toString()).delete();
  }

  @override
  Future<void> batchSaveProblems(List<ProblemStorageDTO> problems) async {
    final ref = _problemsRef();
    if (ref == null) throw StateError('Cannot upload problems without a signed in user');

    final writable = problems.where((problem) => problem.problemId != null).toList();
    if (writable.isEmpty) return;

    for (var start = 0; start < writable.length; start += _batchSizeLimit) {
      final end = (start + _batchSizeLimit).clamp(0, writable.length);
      final batch = _firestore.batch();

      for (final problem in writable.sublist(start, end)) {
        batch.set(ref.doc(problem.problemId.toString()), problem.toJson());
      }

      await batch.commit().timeout(_commitTimeout);
    }
  }
}
