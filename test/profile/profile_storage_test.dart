import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/storage/get_storage_service.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      pathProviderChannel,
      (call) async {
        switch (call.method) {
          case 'getApplicationDocumentsDirectory':
            return '/tmp/algorithm_visualizer_profile_test';

          default:
            return null;
        }
      },
    );
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      pathProviderChannel,
      null,
    );
  });
  late GetStorage getStorage;
  late ProfileStorage storage;
  late ProviderContainer container;

  setUp(() async {
    await GetStorage.init('profile_test');

    getStorage = GetStorage('profile_test');

    await getStorage.erase();

    storage = GetProfileStorage(GetStorageService(getStorage));

    container = ProviderContainer(
      overrides: [
        profileStorageInstanceProvider.overrideWithValue(storage),
      ],
    );
  });

  tearDown(() async {
    await getStorage.erase();
    container.dispose();
  });

  group('ProfileStorageState', () {
    test('initial() returns the anonymous username', () {
      final state = ProfileStorageState.initial();
      expect(state.username, defaultName);
    });

    test('copyWith() updates the username', () {
      final state = ProfileStorageState(username: 'Ahmed');
      final updatedState = state.copyWith(username: 'Mohamed');
      expect(updatedState.username, 'Mohamed');
    });

    test('copyWith() keeps the current username when no value is provided', () {
      final state = ProfileStorageState(username: 'Ahmed');
      final updatedState = state.copyWith();
      expect(updatedState.username, 'Ahmed');
    });

    test('copyWith() does not change the original state (immutable)', () {
      final state = ProfileStorageState(username: 'Ahmed');
      final updatedState = state.copyWith(username: 'Mohamed');
      expect(state.username, 'Ahmed');
      expect(updatedState.username, 'Mohamed');
    });

    test('copyWith() accepts an empty username', () {
      final state = ProfileStorageState(username: 'Ahmed');
      final updatedState = state.copyWith(username: '');
      expect(updatedState.username, '');
    });

    test('copyWith() accepts a whitespace username', () {
      final state = ProfileStorageState(username: 'Ahmed');
      final updatedState = state.copyWith(username: ' ');
      expect(updatedState.username, ' ');
    });

    test('copyWith() accepts unicode usernames', () {
      final state = ProfileStorageState(username: 'Ahmed');
      final updatedState = state.copyWith(username: 'أحمد');
      expect(updatedState.username, 'أحمد');
    });
  });

  group('ProfileStorage', () {
    test('getProfileName() returns the saved username', () {
      storage.saveProfileName("Ahmed");
      final result = storage.getProfileName();
      expect(result, 'Ahmed');
    });

    test('getProfileName() returns anonymous when no username exists', () {
      final result = storage.getProfileName();
      expect(result, StringsManager.anonymous);
    });

    test('getProfileName() returns an empty username when it was saved', () {
      storage.saveProfileName("");
      final result = storage.getProfileName();
      expect(result, '');
    });

    test('saveProfileName() saves the username', () async {
      await storage.saveProfileName('Ahmed');
      expect(storage.getProfileName(), 'Ahmed');
    });

    test('saveProfileName() saves an empty username', () async {
      await storage.saveProfileName('');
      expect(storage.getProfileName(), '');
    });

    test('saveProfileName() saves unicode usernames', () async {
      await storage.saveProfileName('أحمد');
      expect(storage.getProfileName(), 'أحمد');
    });
  });

  group('ProfileStorageNotifier', () {
    test('build() loads the username from storage', () {
      // Arrange
      storage.saveProfileName("Ahmed");

      // Act
      final state = container.read(profileStorageProvider);

      // Assert
      expect(state.username, 'Ahmed');
    });

    test('build() uses anonymous when storage has no username', () {
      final state = container.read(profileStorageProvider);
      expect(state.username, defaultName);
    });

    test('updateName() updates the state username', () async {
// Arrange
      final notifier = container.read(profileStorageProvider.notifier);

// Act
      await notifier.updateName('Ahmed');

// Assert
      expect(container.read(profileStorageProvider).username, 'Ahmed');
    });

    test('updateName() saves the username to storage', () async {
// Arrange
      final notifier = container.read(profileStorageProvider.notifier);

// Act
      await notifier.updateName('Ahmed');

// Assert
      expect(storage.getProfileName(), 'Ahmed');
    });

    test('updateName() updates the state before the save completes', () async {
// Arrange
      final notifier = container.read(profileStorageProvider.notifier);

// Act
      final saveFuture = notifier.updateName('Ahmed');

// Assert
      expect(container.read(profileStorageProvider).username, 'Ahmed');

      await saveFuture;
    });
    test('updateName() allows an empty username', () async {
// Arrange
      final notifier = container.read(profileStorageProvider.notifier);

// Act
      await notifier.updateName('Ahmed');
      await notifier.updateName('');

// Assert
      expect(container.read(profileStorageProvider).username, 'Ahmed');
      expect(storage.getProfileName(), 'Ahmed');
    });

    test('updateName() doesn\'t allows an empty username', () async {
// Arrange
      final notifier = container.read(profileStorageProvider.notifier);

// Act
      await notifier.updateName('Ahmed');
      await notifier.updateName('');

// Assert
      expect(container.read(profileStorageProvider).username, 'Ahmed');
      expect(storage.getProfileName(), 'Ahmed');
    });

    test('updateName() doesn\'t allows a whitespace username', () async {
// Arrange
      final notifier = container.read(profileStorageProvider.notifier);

// Act
      await notifier.updateName('Ahmed');
      await notifier.updateName('   ');
// Assert
      expect(container.read(profileStorageProvider).username, 'Ahmed');
      expect(storage.getProfileName(), 'Ahmed');
    });
    test('updateName() remove prefix and suffix whitespaces username', () async {
// Arrange
      final notifier = container.read(profileStorageProvider.notifier);

// Act
      await notifier.updateName(' Ahmed ');
// Assert
      expect(container.read(profileStorageProvider).username, 'Ahmed');
      expect(storage.getProfileName(), 'Ahmed');
    });

    test('updateName() allows unicode usernames', () async {
// Arrange
      final notifier = container.read(profileStorageProvider.notifier);

// Act
      await notifier.updateName('أحمد');

// Assert
      expect(container.read(profileStorageProvider).username, 'أحمد');
      expect(storage.getProfileName(), 'أحمد');
    });

    test('updateName() replaces the previous username', () async {
// Arrange
      storage.saveProfileName("Ahmed");

      final notifier = container.read(profileStorageProvider.notifier);

// Make sure the provider is built first.
      expect(container.read(profileStorageProvider).username, 'Ahmed');

// Act
      await notifier.updateName('Mohamed');

// Assert
      expect(container.read(profileStorageProvider).username, 'Mohamed');
      expect(storage.getProfileName(), 'Mohamed');
    });

    test('multiple updateName() calls keep the latest username', () async {
// Arrange
      final notifier = container.read(profileStorageProvider.notifier);

// Act
      await notifier.updateName('Ahmed');
      await notifier.updateName('Mohamed');
      await notifier.updateName('Ali');

// Assert
      expect(container.read(profileStorageProvider).username, 'Ali');
      expect(storage.getProfileName(), 'Ali');
    });
  });
}
