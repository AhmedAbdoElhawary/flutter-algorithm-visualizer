import 'package:algorithm_visualizer/core/storage/get_storage_service.dart';
import 'package:algorithm_visualizer/core/storage/storage_providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      pathProviderChannel,
      (call) async => '/tmp/algorithm_visualizer_storage_providers_test',
    );
    await GetStorage.init();
    await GetStorage.init(appSettingsContainer);
  });

  tearDownAll(() async {
    await GetStorage().erase();
    await GetStorage(appSettingsContainer).erase();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      pathProviderChannel,
      null,
    );
  });

  test('the app box and the settings box are two different containers', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final local = container.read(localStorageProvider);
    final settings = container.read(appSettingsStorageProvider);

    await local.write('theme', 'dark');

    expect(local, isA<GetStorageService>());
    expect(settings, isA<GetStorageService>());
    expect(GetStorage().read<String>('theme'), 'dark');
    expect(settings.has('theme'), isFalse);
    expect(GetStorage(appSettingsContainer).hasData('theme'), isFalse);
  });

  test('clearing the app box leaves the settings alone', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final local = container.read(localStorageProvider);
    final settings = container.read(appSettingsStorageProvider);

    await settings.write('language', 'ar');
    await local.write('problems', <Object>[]);
    await local.clear();

    expect(local.has('problems'), isFalse);
    expect(settings.read<String>('language'), 'ar');
    expect(GetStorage(appSettingsContainer).read<String>('language'), 'ar');
  });
}
