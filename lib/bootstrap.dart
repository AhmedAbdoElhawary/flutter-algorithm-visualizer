import 'package:algorithm_visualizer/core/flavor/flavor_config.dart';
import 'package:algorithm_visualizer/core/logging/firebase_log_config.dart';
import 'package:algorithm_visualizer/core/logging/firebase_logger.dart';
import 'package:algorithm_visualizer/core/material_app/my_app.dart';
import 'package:algorithm_visualizer/core/monitoring/crash_reporter.dart';
import 'package:algorithm_visualizer/core/monitoring/monitoring.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

/// Single shared entry point. Every `lib/main_<flavor>.dart` builds its
/// [FlavorConfig] and hands it here, so boot logic lives in exactly one place.
///
/// Firebase is initialized with **no** [FirebaseOptions]: the native config
/// file bundled by the active flavor (`android/app/src/<flavor>/google-services.json`
/// or the flavor-specific `GoogleService-Info.plist` copied in by the iOS build
/// phase) is the source of truth, so dev/staging/prod each hit their own
/// Firebase project — including isolated Analytics.
///
/// Crash/error/performance reporting is owned by [Monitoring], which runs the
/// whole app inside a guarded zone. It is active in **release builds only**;
/// see that class for why.
Future<void> bootstrap(FlavorConfig config) {
  return Monitoring.start(
    config: config,
    appRunner: () => _boot(config),
  );
}

Future<void> _boot(FlavorConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlavorConfig.initialize(config);
  Monitoring.installErrorHandlers();

  bool firebaseReady = false;
  try {
    await Future.wait([
      GetStorage.init(),
      Firebase.initializeApp(),
    ]);
    firebaseReady = true;
  } catch (error, stackTrace) {
    /// Not rethrown: the app stays usable on local storage alone. It is no
    /// longer silent though — the failure is reported, so a broken Firebase
    /// config in a shipped build surfaces instead of vanishing.
    FirebaseLogger.failure('core', 'initializeApp', error);
    await CrashReporter.instance.recordError(error, stackTrace, context: {'phase': 'Firebase.initializeApp'});
  }

  await Monitoring.activate(config: config, firebaseReady: firebaseReady);

  /// Turn `specificLogs` off to keep the per call lines without the Firestore
  /// SDK's own verbose wire logging.
  await FirebaseLogConfig.apply(specificLogs: true, payloads: true);

  runApp(const ProviderScope(child: MyApp()));
}
