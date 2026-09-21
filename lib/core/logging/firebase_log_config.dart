import 'package:algorithm_visualizer/core/monitoring/crash_reporter.dart';
import 'package:algorithm_visualizer/core/resources/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract final class FirebaseLogConfig {
  static bool enabled = kCustomDebugMode;
  static bool specificLogs = kCustomDebugMode;
  static bool payloads = kCustomDebugMode;

  static Future<void> apply({
    bool enabled = kCustomDebugMode,
    bool specificLogs = true,
    bool payloads = true,
  }) async {
    FirebaseLogConfig.enabled = enabled && kCustomDebugMode;
    FirebaseLogConfig.specificLogs = specificLogs && kCustomDebugMode;
    FirebaseLogConfig.payloads = payloads && kCustomDebugMode;

    try {
      await FirebaseFirestore.setLoggingEnabled(FirebaseLogConfig.specificLogs);
    } catch (error, stackTrace) {
      await CrashReporter.instance
          .recordError(error, stackTrace, context: {'phase': 'Firebase.setLoggingEnabled'});

      /// nice to have logging system, but not a reason to make the app shutdown
    }
  }
}
