import 'package:algorithm_visualizer/features/auth/data/data_sources/local/auth_local_data_source.dart';
import 'package:algorithm_visualizer/features/auth/data/models/auth_user_dto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fakes/in_memory_storage.dart';

void main() {
  const user = AuthUserDTO(id: 'uid-1', name: 'Ada', email: 'ada@test.dev');
  const key = 'auth_current_user';

  AuthLocalDataSourceImpl source([Map<String, Object?>? seed]) => AuthLocalDataSourceImpl(InMemoryStorage(seed));

  test('nothing saved means signed out', () {
    final local = source();

    expect(local.getUser(), isNull);
    expect(local.isLoggedIn(), isFalse);
  });

  test('a saved user reads back the same', () async {
    final local = source();

    await local.saveUser(user);

    expect(local.getUser()?.toJson(), user.toJson());
    expect(local.isLoggedIn(), isTrue);
  });

  test('clearing signs out', () async {
    final local = source();
    await local.saveUser(user);

    await local.clearUser();

    expect(local.getUser(), isNull);
    expect(local.isLoggedIn(), isFalse);
  });

  group('broken saved data means signed out, never a crash', () {
    for (final (name, value) in [
      ('empty', ''),
      ('not JSON', 'not json'),
      ('a JSON list', '[1, 2]'),
      ('the wrong type', 42),
    ]) {
      test(name, () {
        final local = source({key: value});

        expect(local.getUser(), isNull);
        expect(local.isLoggedIn(), isFalse);
      });
    }
  });

  test('an older save with extra or missing fields still reads', () {
    final local = source({key: '{"id": "uid-1", "email": "ada@test.dev", "token": "old"}'});

    expect(local.getUser()?.id, 'uid-1');
    expect(local.getUser()?.name, '');
  });
}
