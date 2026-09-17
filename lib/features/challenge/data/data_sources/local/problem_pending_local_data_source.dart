import 'package:algorithm_visualizer/core/storage/storage.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';

class ProblemPendingLocalDataSource {
  ProblemPendingLocalDataSource(this._storage);

  final LocalStorage _storage;

  static const String _pendingKey = 'pending_problems';
  static const String _deletedKey = 'pending_deleted_problems';

  bool get hasPendingChanges => getPending().isNotEmpty || getDeletedIds().isNotEmpty;

  List<ProblemStorageDTO> getPending() {
    final data = _storage.read<List<dynamic>>(_pendingKey);
    if (data == null) return [];

    return data.map((json) => ProblemStorageDTO.fromJson(Map<String, dynamic>.from(json as Map))).toList();
  }

  List<int> getDeletedIds() {
    final data = _storage.read<List<dynamic>>(_deletedKey);
    if (data == null) return [];

    return data.whereType<num>().map((id) => id.toInt()).toList();
  }

  Future<void> upsert(ProblemStorageDTO problem) async {
    final problemId = problem.problemId;
    if (problemId == null) throw StateError('Problem id cannot be nullable');

    final pending = getPending();
    final index = pending.indexWhere((item) => item.problemId == problemId);

    if (index == -1) {
      pending.add(problem);
    } else {
      pending[index] = problem;
    }

    await _writePending(pending);

    /// as this problem can be user want to delete i, and it's in the queue of deleting, so i will remove it now
    await _writeDeleted(getDeletedIds()..remove(problemId));
  }

  Future<void> markDeleted(int problemId) async {
    await _writePending(getPending()..removeWhere((item) => item.problemId == problemId));

    final deleted = getDeletedIds();
    if (deleted.contains(problemId)) return;

    await _writeDeleted(deleted..add(problemId));
  }

  Future<void> clear() async {
    await _storage.remove(_pendingKey);
    await _storage.remove(_deletedKey);
  }

  Future<void> _writePending(List<ProblemStorageDTO> problems) async {
    final json = [
      for (final problem in problems)
        if (problem.problemId != null) problem.toJson(),
    ];

    await _storage.write(_pendingKey, json);
  }

  Future<void> _writeDeleted(List<int> ids) => _storage.write(_deletedKey, ids);
}
