import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/storage/storage_providers.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/view_model/auth_providers.dart';
import 'package:algorithm_visualizer/features/auth/presentation/signup/view_model/signup_auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fakes/fake_auth_remote_data_source.dart';
import '../../../../../helpers/fakes/in_memory_storage.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        localStorageProvider.overrideWithValue(InMemoryStorage()),
        authRemoteDataSourceProvider.overrideWithValue(FakeAuthRemoteDataSource()),
      ],
    );
    addTearDown(container.dispose);
  });

  String? nameErrorFor(String name) {
    container.read(authSignupProvider.notifier)
      ..setName(name)
      ..validateSignUp();
    return container.read(authSignupProvider).nameError;
  }

  group('the name', () {
    test('up to 50 characters is fine, the same cap as renaming', () {
      expect(nameErrorFor('A' * 50), isNull);
    });

    test('51 characters is too long', () {
      expect(nameErrorFor('A' * 51), StringsManager.nameMaxLength);
    });
  });
}
