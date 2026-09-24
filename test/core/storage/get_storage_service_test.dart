import 'package:algorithm_visualizer/core/storage/get_storage_service.dart';
import 'package:flutter/services.dart';
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

  late GetStorage storage;
  late GetStorageService storageService;

  setUp(() async {
    await GetStorage.init('test');

    storage = GetStorage('test');
    storageService = GetStorageService(storage);

    await storage.erase();
  });

  tearDown(() async {
    await storage.erase();
  });

  group('GetStorageService', () {
    group('write()', () {
      test('writes a value to storage', () async {
        await storageService.write('name', 'Ahmed');

        expect(storage.read<String>('name'), 'Ahmed');
      });

      test('overwrites an existing value', () async {
        await storageService.write('name', 'Ahmed');

        await storageService.write('name', 'Mohamed');

        expect(storage.read<String>('name'), 'Mohamed');
      });

      test('writes an integer value', () async {
        await storageService.write('age', 25);

        expect(storage.read<int>('age'), 25);
      });

      test('writes a boolean value', () async {
        await storageService.write('isLoggedIn', true);

        expect(storage.read<bool>('isLoggedIn'), true);
      });

      test('writes a double value', () async {
        await storageService.write('height', 183.5);

        expect(storage.read<double>('height'), 183.5);
      });

      test('writes a list value', () async {
        final value = <String>['Flutter', 'Dart'];

        await storageService.write('skills', value);

        expect(storage.read<List<String>>('skills'), value);
      });

      test('writes an empty string', () async {
        await storageService.write('name', '');

        expect(storage.read<String>('name'), '');
      });
    });

    group('read()', () {
      test('reads an existing value', () async {
        await storage.write('name', 'Ahmed');

        final result = storageService.read<String>('name');

        expect(result, 'Ahmed');
      });

      test('returns null when the key does not exist', () {
        final result = storageService.read<String>('name');

        expect(result, isNull);
      });

      test('reads an integer value', () async {
        await storage.write('age', 25);

        final result = storageService.read<int>('age');

        expect(result, 25);
      });

      test('reads a boolean value', () async {
        await storage.write('isLoggedIn', true);

        final result = storageService.read<bool>('isLoggedIn');

        expect(result, true);
      });

      test('reads a double value', () async {
        await storage.write('height', 183.5);

        final result = storageService.read<double>('height');

        expect(result, 183.5);
      });

      test('reads an empty string', () async {
        await storage.write('name', '');

        final result = storageService.read<String>('name');

        expect(result, '');
      });
    });

    group('remove()', () {
      test('removes an existing value', () async {
        await storageService.write('name', 'Ahmed');

        await storageService.remove('name');

        expect(storageService.read<String>('name'), isNull);
      });

      test('does nothing when the key does not exist', () async {
        await storageService.remove('missing_key');

        expect(storageService.read<String>('missing_key'), isNull);
      });

      test('removes only the requested key', () async {
        await storageService.write('name', 'Ahmed');
        await storageService.write('age', 25);

        await storageService.remove('name');

        expect(storageService.read<String>('name'), isNull);
        expect(storageService.read<int>('age'), 25);
      });
    });

    group('clear()', () {
      test('removes all values from storage', () async {
        await storageService.write('name', 'Ahmed');
        await storageService.write('age', 25);
        await storageService.write('isLoggedIn', true);

        await storageService.clear();

        expect(storageService.read<String>('name'), isNull);
        expect(storageService.read<int>('age'), isNull);
        expect(storageService.read<bool>('isLoggedIn'), isNull);
      });

      test('does nothing when storage is already empty', () async {
        await storageService.clear();

        expect(storageService.has('name'), false);
      });
    });

    group('has()', () {
      test('returns true when the key exists', () async {
        await storageService.write('name', 'Ahmed');

        expect(storageService.has('name'), true);
      });

      test('returns false when the key does not exist', () {
        expect(storageService.has('name'), false);
      });

      test('returns true when the stored value is an empty string', () async {
        await storageService.write('name', '');

        expect(storageService.has('name'), true);
      });

      test('returns false after the key is removed', () async {
        await storageService.write('name', 'Ahmed');

        await storageService.remove('name');

        expect(storageService.has('name'), false);
      });

      test('returns false after storage is cleared', () async {
        await storageService.write('name', 'Ahmed');

        await storageService.clear();

        expect(storageService.has('name'), false);
      });
    });
  });
}
