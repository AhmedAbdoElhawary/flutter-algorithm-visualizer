import 'dart:io';

import 'package:algorithm_visualizer/core/flavor/flavor_config.dart';
import 'package:algorithm_visualizer/core/helpers/app_info.dart';
import 'package:algorithm_visualizer/core/logging/firebase_log_config.dart';
import 'package:algorithm_visualizer/core/logging/firebase_logger.dart';
import 'package:algorithm_visualizer/core/material_app/splash_gate.dart';
import 'package:algorithm_visualizer/core/monitoring/crash_reporter.dart';
import 'package:algorithm_visualizer/core/monitoring/monitoring.dart';
import 'package:algorithm_visualizer/core/resources/constants.dart';
import 'package:algorithm_visualizer/core/storage/storage_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:leak_tracker/leak_tracker.dart';

const _useFirebaseEmulator = bool.fromEnvironment('USE_FIREBASE_EMULATOR');

/// Keep in sync with `firebase.json`.
const _authEmulatorPort = 9099;
const _firestoreEmulatorPort = 8080;

Future<void> bootstrap(FlavorConfig config) {
  return Monitoring.start(
    config: config,
    appRunner: () => _boot(config),
  );
}

Future<void> _boot(FlavorConfig config) async {
  await prepareApp(config);
  runApp(const ProviderScope(child: SplashGate()));
}

/// Everything [bootstrap] does before `runApp`, public so integration tests start the app the same way.
/// Returns whether Firebase came up.
Future<bool> prepareApp(FlavorConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();

  /// TODO: change it after MVP
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  _startLeakTracking();

  FlavorConfig.initialize(config);
  Monitoring.installErrorHandlers();

  /// Before `runApp`, so Settings never renders the empty default.
  await AppInfo.load();

  final useEmulator = _useEmulatorFor(config);
  bool firebaseReady = false;
  try {
    await Future.wait([
      GetStorage.init(),
      GetStorage.init(appSettingsContainer),
      Firebase.initializeApp(),
    ]);
    firebaseReady = true;
    if (useEmulator) {
      await _connectToEmulator();
    } else {
      await _activateAppCheck();
    }
  } catch (error, stackTrace) {
    FirebaseLogger.failure('core', 'initializeApp', error);
    await CrashReporter.instance.recordError(error, stackTrace, context: {'phase': 'Firebase.initializeApp'});
  }

  /// No Analytics against the emulator, so test runs never reach the real dashboard.
  await Monitoring.activate(config: config, firebaseReady: firebaseReady && !useEmulator);

  await FirebaseLogConfig.apply();

  return firebaseReady;
}

/// Only the dev flavor may talk to the local emulator, so a stray flag can't cut staging or production off
/// their real project.
bool _useEmulatorFor(FlavorConfig config) {
  if (!_useFirebaseEmulator) return false;
  if (config.flavor.isDev) return true;
  FirebaseLogger.failure('core', 'USE_FIREBASE_EMULATOR', StateError('ignored outside the dev flavor'));
  return false;
}

Future<void> _connectToEmulator() async {
  /// The Android emulator reaches the host machine through 10.0.2.2.
  final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
  await FirebaseAuth.instance.useAuthEmulator(host, _authEmulatorPort);
  FirebaseFirestore.instance.useFirestoreEmulator(host, _firestoreEmulatorPort);
}

/// Debug only, so leaked controllers and notifiers print to the console while using the app.
void _startLeakTracking() {
  if (!kDebugMode) return;
  var notDisposed = 0;
  LeakTracking.start(
    config: LeakTrackingConfig(
      /// not GCed and GCed late keep growing in a running app since gc is never forced, only not disposed is a real bug.
      stdoutLeaks: false,
      onLeaks: (summary) {
        final count = summary.totals[LeakType.notDisposed] ?? 0;
        if (count == notDisposed) return;
        notDisposed = count;
        debugPrint('leak_tracker: $count not disposed');
      },
    ),
  );
  FlutterMemoryAllocations.instance.addListener(
    (event) => LeakTracking.dispatchObjectEvent(event.toMap()),
  );
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
