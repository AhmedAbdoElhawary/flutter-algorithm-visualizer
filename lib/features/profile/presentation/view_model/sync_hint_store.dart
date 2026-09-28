import 'package:algorithm_visualizer/core/storage/storage.dart';
import 'package:algorithm_visualizer/core/storage/storage_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class SyncHintStore {
  const SyncHintStore(this._storage);

  static const String seenKey = 'sync_hint_seen';

  final LocalStorage _storage;

  /// Read as `Object`, so a corrupted value means "not seen" instead of a cast error.
  bool get isSeen => _storage.read<Object>(seenKey) == true;

  Future<void> markSeen() => _storage.write<bool>(seenKey, true);
}

final syncHintStoreProvider = Provider.autoDispose<SyncHintStore>(
  (ref) => SyncHintStore(ref.watch(localStorageProvider)),
);
