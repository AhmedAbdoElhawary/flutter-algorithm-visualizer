import 'package:algorithm_visualizer/core/flavor/flavor_config.dart';
import 'package:algorithm_visualizer/core/logging/firebase_log_config.dart';
import 'package:algorithm_visualizer/core/logging/firebase_logger.dart';
import 'package:algorithm_visualizer/core/material_app/my_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

/// Single shared entry point. Every `lib/main_<flavor>.dart` builds its
/// [FlavorConfig] and hands it here, so boot logic lives in exactly one place.
///
/// Firebase is initialized with **no** `FirebaseOptions`: the native config
/// file bundled by the active flavor (`android/app/src/<flavor>/google-services.json`
/// or the flavor-specific `GoogleService-Info.plist` copied in by the iOS build
/// phase) is the source of truth, so dev/staging/prod each hit their own
/// Firebase project — including isolated Crashlytics / Analytics / Remote Config.
Future<void> bootstrap(FlavorConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlavorConfig.initialize(config);

  try {
    await Future.wait([
      GetStorage.init(),
      Firebase.initializeApp(),
    ]);
  } catch (error) {
    /// Not rethrown: the app stays usable on local storage alone. In debug the
    /// reason is at least printed instead of vanishing.
    FirebaseLogger.failure('core', 'initializeApp', error);
  }

  /// Turn `specificLogs` off to keep the per call lines without the Firestore
  /// SDK's own verbose wire logging.
  await FirebaseLogConfig.apply(specificLogs: true, payloads: true);

  runApp(const ProviderScope(child: MyApp()));
}
