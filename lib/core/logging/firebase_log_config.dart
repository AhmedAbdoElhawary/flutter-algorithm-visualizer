import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Switchboard for the Firebase call tracking.
///
/// Two independent levels are available:
/// * [enabled] turns on the app level logs, one readable line per call that the
///   app makes through a remote data source.
/// * [specificLogs] turns on the Firestore SDK's own verbose logging, the wire
///   traffic underneath those calls.
///
/// Everything is forced off outside debug builds, see [apply].
abstract final class FirebaseLogConfig {
  /// App level per call logs coming from the logging data source decorators.
  static bool enabled = kDebugMode;

  /// Firestore's native verbose logging: watch streams, handshakes, cache
  /// versus server reads. Very noisy, so it stays opt in.
  ///
  /// The output comes from the native SDK, not from Dart, so it shows up in
  /// `flutter run` / logcat on Android and in the Xcode console on iOS.
  ///
  /// Initialised to [kDebugMode], not to `true`: [apply] already ANDs every
  /// flag with it, but a field that reads `true` unconditionally would leak
  /// into a release build the moment somebody adds a code path that skips
  /// [apply]. The default carries the guarantee instead of relying on a call.
  static bool specificLogs = kDebugMode;

  /// Prints full document payloads and argument values instead of the redacted
  /// summaries. Secrets (passwords, reset codes, tokens) stay redacted anyway.
  ///
  /// [kDebugMode] for the same reason as [specificLogs]: this is the flag that
  /// un-redacts emails and uids, so it is the one that must never default on.
  static bool payloads = kDebugMode;

  /// Applies the configuration. Call it once after `Firebase.initializeApp`.
  ///
  /// Release builds get nothing, whatever the caller asks for.
  static Future<void> apply({
    bool enabled = kDebugMode,
    bool specificLogs = true,
    bool payloads = true,
  }) async {
    FirebaseLogConfig.enabled = enabled && kDebugMode;
    FirebaseLogConfig.specificLogs = specificLogs && kDebugMode;
    FirebaseLogConfig.payloads = payloads && kDebugMode;

    try {
      await FirebaseFirestore.setLoggingEnabled(FirebaseLogConfig.specificLogs);
    } catch (_) {
      /// Firebase never came up, `main` swallows that failure. Losing the
      /// native logs is not a reason to take the app down with it.
    }
  }
}
