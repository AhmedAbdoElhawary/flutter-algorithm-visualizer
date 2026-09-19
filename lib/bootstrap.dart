import 'package:algorithm_visualizer/core/flavor/flavor_config.dart';
import 'package:algorithm_visualizer/core/logging/firebase_log_config.dart';
import 'package:algorithm_visualizer/core/logging/firebase_logger.dart';
import 'package:algorithm_visualizer/core/material_app/splash_gate.dart';
import 'package:algorithm_visualizer/core/monitoring/crash_reporter.dart';
import 'package:algorithm_visualizer/core/monitoring/monitoring.dart';
import 'package:algorithm_visualizer/core/storage/storage_providers.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Attests that requests are coming from this app, not from a script.
///
/// The Firebase API key ships inside the APK — that is by design, it is an
/// identifier and not a secret. What it means, though, is that anyone can pull
/// it out of the binary and call the Auth endpoint directly: create accounts in
/// a loop, fire password-reset mail at arbitrary addresses, and burn the
/// project's quota. App Check is what closes that, by having Play Integrity
/// vouch for the binary before Firebase answers.
///
/// Registering here does nothing on its own. Enforcement is a switch in the
/// Firebase console, per product, and it should stay **off** until the App
/// Check dashboard shows traffic arriving verified — turning it on first locks
/// out every already-installed copy of the app.
///
/// Failure is swallowed for the same reason `Firebase.initializeApp` is: a
/// device with no Play Services should still get a working, local-only app.
Future<void> _activateAppCheck() async {
  try {
    await FirebaseAppCheck.instance.activate(
      /// Debug provider off-device and in dev/staging: Play Integrity refuses
      /// to attest a build that did not come from Play, so a debug build would
      /// fail every check. The debug token is printed to the console on first
      /// run and has to be pasted into the Firebase console once per machine.
      providerAndroid: kReleaseMode ? const AndroidPlayIntegrityProvider() : const AndroidDebugProvider(),
      providerApple: kReleaseMode ? const AppleDeviceCheckProvider() : const AppleDebugProvider(),
    );
  } catch (error, stackTrace) {
    FirebaseLogger.failure('core', 'appCheck.activate', error);
    await CrashReporter.instance.recordError(error, stackTrace, context: {'phase': 'AppCheck.activate'});
  }
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

  bool firebaseReady = false;
  try {
    await Future.wait([
      GetStorage.init(),

      /// The settings box is a *separate* container, and `GetStorage` does not
      /// load one off disk until it is initialized by name. Without this line
      /// the theme and language the user picked read back as `null` on every
      /// launch, which looks exactly like the preference was never saved.
      GetStorage.init(appSettingsContainer),
      Firebase.initializeApp(),
    ]);
    firebaseReady = true;
    await _activateAppCheck();
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

  runApp(const ProviderScope(child: SplashGate()));
}
