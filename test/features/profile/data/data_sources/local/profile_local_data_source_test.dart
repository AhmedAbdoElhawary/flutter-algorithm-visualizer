import 'package:algorithm_visualizer/features/profile/data/data_sources/local/profile_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fakes/in_memory_storage.dart';

void main() {
  const key = ProfileLocalDataSourceImpl.guestDisplayNameKey;

  ProfileLocalDataSourceImpl source([Map<String, Object?>? seed]) =>
      ProfileLocalDataSourceImpl(InMemoryStorage(seed));

  test('nothing saved means no name', () {
    expect(source().getDisplayName(), isNull);
  });

  test('a saved name reads back trimmed', () async {
    final local = source();

    await local.saveDisplayName('  Ada  ');

    expect(local.getDisplayName(), 'Ada');
  });

  test('clearing forgets the name', () async {
    final local = source();
    await local.saveDisplayName('Ada');

    await local.clearDisplayName();

    expect(local.getDisplayName(), isNull);
  });

  group('broken saved data means no name, never a crash', () {
    for (final (name, value) in [
      ('empty', ''),
      ('only spaces', '   '),
      ('the wrong type', 42),
    ]) {
      test(name, () {
        expect(source({key: value}).getDisplayName(), isNull);
      });
    }
  });
}
