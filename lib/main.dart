import 'package:algorithm_visualizer/core/logging/firebase_log_config.dart';
import 'package:algorithm_visualizer/core/logging/firebase_logger.dart';
import 'package:algorithm_visualizer/core/material_app/my_app.dart';
import 'package:algorithm_visualizer/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Future.wait([
      GetStorage.init(),
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    ]);
  } catch (error) {
    /// Still not rethrown, the app stays usable on local storage alone. In
    /// debug the reason is at least printed instead of vanishing.
    FirebaseLogger.failure('core', 'initializeApp', error);
  }

  /// Turn `specificLogs` off to keep the per call lines without the Firestore
  /// SDK's own verbose wire logging.
  await FirebaseLogConfig.apply(specificLogs: true,payloads: true);

  runApp(const ProviderScope(child: MyApp()));
}
