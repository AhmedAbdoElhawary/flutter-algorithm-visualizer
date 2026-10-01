import 'package:algorithm_visualizer/core/logging/firebase_log_config.dart';
import 'package:algorithm_visualizer/core/monitoring/crash_reporter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes/recording_crash_reporter.dart';

void main() {
  late RecordingCrashReporter reporter;

  setUp(() {
    reporter = RecordingCrashReporter();
    CrashReporter.instance = reporter;
  });

  tearDown(() async {
    CrashReporter.instance = const DebugCrashReporter();
    FirebaseLogConfig.enabled = kDebugMode;
    FirebaseLogConfig.specificLogs = kDebugMode;
    FirebaseLogConfig.payloads = kDebugMode;
  });

  test('in a debug build, every switch follows what it is given', () async {
    await FirebaseLogConfig.apply(enabled: true, specificLogs: false, payloads: true);

    expect(FirebaseLogConfig.enabled, isTrue);
    expect(FirebaseLogConfig.specificLogs, isFalse);
    expect(FirebaseLogConfig.payloads, isTrue);

    await FirebaseLogConfig.apply(enabled: false, specificLogs: true, payloads: false);

    expect(FirebaseLogConfig.enabled, isFalse);
    expect(FirebaseLogConfig.specificLogs, isTrue);
    expect(FirebaseLogConfig.payloads, isFalse);
  });

  test('Firestore failing to switch its own logs is reported, never thrown', () async {
    // With no Firebase app in a test, the Firestore call fails, just as it would with a broken setup.
    await FirebaseLogConfig.apply();

    expect(reporter.errors.single.context, {'phase': 'Firebase.setLoggingEnabled'});
    expect(reporter.errors.single.fatal, isFalse);
  });
}
