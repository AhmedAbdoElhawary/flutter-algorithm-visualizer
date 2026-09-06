import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Persists the per-user problem progress ([ProblemStorageDTO]) in Firestore so
/// it follows the signed-in account across devices.
///
/// Layout: `users/{uid}/problems/{problemId}` where each document is the JSON of
/// a [ProblemStorageDTO]. Kept intentionally simple for now; edge cases (merge
/// conflicts, offline queueing, etc.) are handled elsewhere later.
class ProblemRemoteDataSource {
  ProblemRemoteDataSource();
  late final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get isSignedIn => _auth.currentUser != null;

  CollectionReference<Map<String, dynamic>>? _problemsRef() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('problems');
  }

  Future<List<ProblemStorageDTO>> getProblems() async {
    final ref = _problemsRef();
    if (ref == null) return [];

    final snapshot = await ref.get();
    return snapshot.docs.map((doc) => ProblemStorageDTO.fromJson(doc.data())).toList();
  }

  Future<void> saveProblem(ProblemStorageDTO problem) async {
    final ref = _problemsRef();
    if (ref == null || problem.problemId == null) return;

    await ref.doc(problem.problemId.toString()).set(problem.toJson());
  }

  Future<void> updateProblem(ProblemStorageDTO problem) => saveProblem(problem);

  Future<void> deleteProblem(int problemId) async {
    final ref = _problemsRef();
    if (ref == null) return;

    await ref.doc(problemId.toString()).delete();
  }
}
