import 'package:algorithm_visualizer/core/flavor/flavor_config.dart';
import 'package:algorithm_visualizer/core/helpers/app_info.dart';
import 'package:algorithm_visualizer/core/logging/firebase_log_config.dart';
import 'package:algorithm_visualizer/core/logging/firebase_logger.dart';
import 'package:algorithm_visualizer/core/material_app/splash_gate.dart';
import 'package:algorithm_visualizer/core/monitoring/crash_reporter.dart';
import 'package:algorithm_visualizer/core/monitoring/monitoring.dart';
import 'package:algorithm_visualizer/core/resources/constants.dart';
import 'package:algorithm_visualizer/core/storage/storage_providers.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

Future<void> bootstrap(FlavorConfig config) {
  return Monitoring.start(
    config: config,
    appRunner: () => _boot(config),
  );
}

Future<void> _boot(FlavorConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();

  /// TODO: change it after MVP
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  FlavorConfig.initialize(config);
  Monitoring.installErrorHandlers();

  /// Before `runApp`, so Settings never renders the empty default.
  await AppInfo.load();

  bool firebaseReady = false;
  try {
    await Future.wait([
      GetStorage.init(),
      GetStorage.init(appSettingsContainer),
      Firebase.initializeApp(),
    ]);
    firebaseReady = true;
    await _activateAppCheck();
  } catch (error, stackTrace) {
    FirebaseLogger.failure('core', 'initializeApp', error);
    await CrashReporter.instance.recordError(error, stackTrace, context: {'phase': 'Firebase.initializeApp'});
  }

  await Monitoring.activate(config: config, firebaseReady: firebaseReady);

  await FirebaseLogConfig.apply();

  runApp(const ProviderScope(child: SplashGate()));
}

Future<void> _activateAppCheck() async {
  try {
    await FirebaseAppCheck.instance.activate(
      providerAndroid:
          kCustomReleaseMode ? const AndroidPlayIntegrityProvider() : const AndroidDebugProvider(),
      providerApple: kCustomReleaseMode ? const AppleDeviceCheckProvider() : const AppleDebugProvider(),
    );
  } catch (error, stackTrace) {
    FirebaseLogger.failure('core', 'appCheck.activate', error);
    await CrashReporter.instance.recordError(error, stackTrace, context: {'phase': 'AppCheck.activate'});
  }
}
