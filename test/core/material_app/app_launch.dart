import 'dart:io';

import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/helpers/storage/app_settings/app_settings_cubit.dart';
import 'package:algorithm_visualizer/core/storage/storage_providers.dart';
import 'package:algorithm_visualizer/features/onboarding/view_model/onboarding_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';

import '../../helpers/test_container.dart';

/// The app's router is built once per test file and reads the real default box, as it does on a phone.
/// So each file picks one launch: a first one, or one after onboarding.
void setUpLaunch({required bool onboardingSeen}) {
  TestWidgetsFlutterBinding.ensureInitialized();
  const pathProvider = MethodChannel('plugins.flutter.io/path_provider');

  late Directory folder;

  setUpAll(() async {
    // Test files run side by side, and each would lock the other out of a shared box file.
    folder = Directory.systemTemp.createTempSync('launch_test');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      pathProvider,
      (call) async => folder.path,
    );
    await GetStorage.init();
    await GetStorage().erase();
    if (onboardingSeen) await GetStorage().write(OnboardingStore.seenKey, true);
  });

  tearDownAll(() async {
    // The router lives as long as the app, so only the end of the file can let it go.
    AppRoutes.instance.routerProvider.dispose();
    await GetStorage().erase();
    folder.deleteSync(recursive: true);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      pathProvider,
      null,
    );
  });
}

/// Pumps [app] with fakes behind it, and [theme] already saved as if chosen on an earlier launch.
Future<ProviderContainer> pumpLaunch(WidgetTester tester, Widget app, {ThemeMode? theme}) async {
  final container = createTestContainer();
  if (theme != null) {
    await container.read(appSettingsStorageProvider).write(AppSettingsNotifier.themeModeKey, theme.name);
  }
  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: app));
  return container;
}
