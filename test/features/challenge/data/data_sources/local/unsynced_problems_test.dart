import 'package:algorithm_visualizer/features/challenge/data/data_sources/local/unsynced_problems.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fakes/in_memory_storage.dart';

void main() {
  late InMemoryStorage storage;
  late UnsyncedProblems unsynced;

  setUp(() {
    storage = InMemoryStorage();
    unsynced = UnsyncedProblems(storage);
  });

  test('starts with nothing to sync', () {
    expect(unsynced.needsToBeUploadedIds, isEmpty);
    expect(unsynced.needsToBeDeletedIds, isEmpty);
    expect(unsynced.hasAny, isFalse);
  });

  test('marking an upload twice keeps one mark', () async {
    await unsynced.needsToBeUploaded(1);
    await unsynced.needsToBeUploaded(1);

    expect(unsynced.needsToBeUploadedIds, [1]);
    expect(unsynced.hasAny, isTrue);
  });

  test('an id is only ever in one list, the latest wins', () async {
    await unsynced.needsToBeUploaded(1);
    await unsynced.needsToBeDeleted(1);

    expect(unsynced.needsToBeUploadedIds, isEmpty);
    expect(unsynced.needsToBeDeletedIds, [1]);

    await unsynced.needsToBeUploaded(1);

    expect(unsynced.needsToBeUploadedIds, [1]);
    expect(unsynced.needsToBeDeletedIds, isEmpty);
  });

  test('several uploads merge without duplicates', () async {
    await unsynced.needsToBeUploaded(2);

    await unsynced.severalNeedsToBeUploaded([1, 2, 3]);

    expect(unsynced.needsToBeUploadedIds, unorderedEquals([1, 2, 3]));
  });

  test('clearing what synced keeps what came in meanwhile', () async {
    await unsynced.severalNeedsToBeUploaded([1, 2]);
    await unsynced.needsToBeDeleted(5);

    await unsynced.clearUnSync(uploadedSynced: [1], deletedSynced: [5]);

    expect(unsynced.needsToBeUploadedIds, [2]);
    expect(unsynced.needsToBeDeletedIds, isEmpty);
  });

  test('clear forgets everything', () async {
    await unsynced.needsToBeUploaded(1);
    await unsynced.needsToBeDeleted(2);

    await unsynced.clear();

    expect(unsynced.hasAny, isFalse);
  });

  group('broken storage reads as nothing to sync, never a crash', () {
    for (final (label, value) in [('a string', 'oops'), ('a map', {'id': 1})]) {
      test(label, () {
        final broken = UnsyncedProblems(InMemoryStorage({'unsynced_problem_ids': value}));

        expect(broken.needsToBeUploadedIds, isEmpty);
      });
    }

    test('non-numbers inside the list are skipped', () {
      final mixed = UnsyncedProblems(InMemoryStorage({'unsynced_problem_ids': [1, 'two', 3.0, null]}));

      expect(mixed.needsToBeUploadedIds, [1, 3]);
    });
  });
}
