import 'dart:io';

import 'package:algorithm_visualizer/core/flavor/flavor_config.dart';
import 'package:algorithm_visualizer/core/logging/firebase_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:leak_tracker/leak_tracker.dart';

const _useFirebaseEmulator = bool.fromEnvironment('USE_FIREBASE_EMULATOR');

/// Keep in sync with `firebase.json`.
const _authEmulatorPort = 9099;
const _firestoreEmulatorPort = 8080;

/// Debug only, so leaked controllers and notifiers print to the console while using the app.
void startLeakTracking() {
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

/// Only the dev flavor may talk to the local emulator, so a stray flag can't cut staging or production off
/// their real project.
bool useEmulatorFor(FlavorConfig config) {
  if (!_useFirebaseEmulator) return false;
  if (config.flavor.isDev) return true;
  FirebaseLogger.failure('core', 'USE_FIREBASE_EMULATOR', StateError('ignored outside the dev flavor'));
  return false;
}

Future<void> connectToEmulator() async {
  /// The Android emulator reaches the host machine through 10.0.2.2.
  final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
  await FirebaseAuth.instance.useAuthEmulator(host, _authEmulatorPort);
  FirebaseFirestore.instance.useFirestoreEmulator(host, _firestoreEmulatorPort);
}
