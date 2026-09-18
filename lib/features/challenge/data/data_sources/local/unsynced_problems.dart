import 'package:algorithm_visualizer/core/storage/storage.dart';

/// ids only, the problems themselves stay in the one `problems` store
class UnsyncedProblems {
  UnsyncedProblems(this._storage);

  final LocalStorage _storage;

  static const String _needsToBeUploadedKey = 'unsynced_problem_ids';
  static const String _needsToBeDeletedKey = 'unsynced_deleted_problem_ids';

  List<int> get needsToBeUploadedIds => _readIds(_needsToBeUploadedKey);

  /// separate because a delete has no local copy left to upload
  List<int> get needsToBeDeletedIds => _readIds(_needsToBeDeletedKey);

  bool get hasAny => needsToBeUploadedIds.isNotEmpty || needsToBeDeletedIds.isNotEmpty;

  /// an id is only ever in one list
  Future<void> needsToBeUploaded(int problemId) async {
    await _write(_needsToBeDeletedKey, needsToBeDeletedIds..remove(problemId));

    final toBeUploaded = needsToBeUploadedIds;
    if (toBeUploaded.contains(problemId)) return;

    await _write(_needsToBeUploadedKey, toBeUploaded..add(problemId));
  }

  Future<void> needsToBeDeleted(int problemId) async {
    await _write(_needsToBeUploadedKey, needsToBeUploadedIds..remove(problemId));

    final toBeDeleted = needsToBeDeletedIds;
    if (toBeDeleted.contains(problemId)) return;

    await _write(_needsToBeDeletedKey, toBeDeleted..add(problemId));
  }

  Future<void> severalNeedsToBeUploaded(Iterable<int> problemIds) async {
    await _write(_needsToBeUploadedKey, {...needsToBeUploadedIds, ...problemIds}.toList());
  }

  Future<void> clearUnSync({required List<int> uploadedSynced, required List<int> deletedSynced}) async {
    await _write(
        _needsToBeUploadedKey, needsToBeUploadedIds.where((id) => !uploadedSynced.contains(id)).toList());
    await _write(
        _needsToBeDeletedKey, needsToBeDeletedIds.where((id) => !deletedSynced.contains(id)).toList());
  }

  Future<void> clear() async {
    await _storage.remove(_needsToBeUploadedKey);
    await _storage.remove(_needsToBeDeletedKey);
  }

  List<int> _readIds(String key) {
    final data = _storage.read<List<dynamic>>(key);
    if (data == null) return [];

    return data.whereType<num>().map((id) => id.toInt()).toList();
  }

  Future<void> _write(String key, List<int> ids) => _storage.write(key, ids);
}
