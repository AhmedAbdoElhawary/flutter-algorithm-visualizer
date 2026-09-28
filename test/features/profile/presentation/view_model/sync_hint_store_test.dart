import 'package:algorithm_visualizer/core/storage/storage_providers.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/sync_hint_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes/in_memory_storage.dart';
import '../../../../helpers/test_container.dart';

void main() {
  test('the hint shows until it is marked seen, then stays hidden', () async {
    final storage = InMemoryStorage();

    expect(SyncHintStore(storage).isSeen, isFalse);

    await SyncHintStore(storage).markSeen();

    // A fresh store, as after an app restart.
    expect(SyncHintStore(storage).isSeen, isTrue);
  });

  test('a corrupted flag shows the hint instead of crashing', () {
    expect(SyncHintStore(InMemoryStorage({SyncHintStore.seenKey: 'yes'})).isSeen, isFalse);
  });

  test('the provider reads the app storage', () async {
    final container = createTestContainer();
    await container.read(localStorageProvider).write(SyncHintStore.seenKey, true);

    expect(container.read(syncHintStoreProvider).isSeen, isTrue);
  });
}
