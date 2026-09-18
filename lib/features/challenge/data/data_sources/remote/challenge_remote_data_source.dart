import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class ProblemRemoteDataSource {
  bool get isSignedIn;

  Future<List<ProblemStorageDTO>> getProblems();
  Future<void> saveProblem(ProblemStorageDTO problem);
  Future<void> updateProblem(ProblemStorageDTO problem);
  Future<void> deleteProblem(int problemId);

  Future<void> batchSaveProblems(List<ProblemStorageDTO> problems);

  Future<void> batchDeleteProblems(List<int> problemIds);
  Future<void> deleteAllProblems();
}

class ProblemRemoteDataSourceImpl implements ProblemRemoteDataSource {
  ProblemRemoteDataSourceImpl();

  late final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final FirebaseAuth _auth = FirebaseAuth.instance;

  /// firestore not allow a batch above 500 writes
  static const int _batchSizeLimit = 450;

  static const Duration _commitTimeout = Duration(seconds: 15);

  @override
  bool get isSignedIn {
    try {
      return _auth.currentUser != null;
    } catch (_) {
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

    /// plain get() serves the server when online, its own cache when not
    return _toDTOs(await ref.get());
  }

  List<ProblemStorageDTO> _toDTOs(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map((doc) => ProblemStorageDTO.fromJson(doc.data())).toList();
  }

  @override
  Future<void> saveProblem(ProblemStorageDTO problem) async {
    final ref = _problemsRef();
    if (ref == null || problem.problemId == null) return;

    /// todo: look to this again:
    /// it's freezed while the device offline when write await, as it's waiting the network/server
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

  @override
  Future<void> batchDeleteProblems(List<int> problemIds) async {
    final ref = _problemsRef();
    if (ref == null) throw StateError('Cannot delete problems without a signed in user');

    if (problemIds.isEmpty) return;

    for (var start = 0; start < problemIds.length; start += _batchSizeLimit) {
      final end = (start + _batchSizeLimit).clamp(0, problemIds.length);
      final batch = _firestore.batch();

      for (final problemId in problemIds.sublist(start, end)) {
        batch.delete(ref.doc(problemId.toString()));
      }

      await batch.commit().timeout(_commitTimeout);
    }
  }

  @override
  Future<void> deleteAllProblems() async {
    final ref = _problemsRef();
    if (ref == null) return;

    final snapshot = await ref.get().timeout(_commitTimeout);
    if (snapshot.docs.isEmpty) return;

    for (var start = 0; start < snapshot.docs.length; start += _batchSizeLimit) {
      final end = (start + _batchSizeLimit).clamp(0, snapshot.docs.length);
      final batch = _firestore.batch();

      for (final doc in snapshot.docs.sublist(start, end)) {
        batch.delete(doc.reference);
      }

      await batch.commit().timeout(_commitTimeout);
    }
  }
}
