import 'package:algorithm_visualizer/core/logging/firebase_log_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Prints one line when a Firebase call starts and one when it settles, so the
/// console shows what the app asked Firebase for, how long it took and how it
/// ended.
///
/// ```
/// [FB#7][auth] → login(email: a***@gmail.com)
/// [FB#7][auth] ✓ login  412ms  uid=x9K2wq
/// [FB#8][firestore] ✗ deleteProblem(id: 14)  90ms  FirebaseException(permission-denied)
/// ```
///
/// Every entry carries a sequence number, interleaved async calls stay pairable
/// that way. Nothing is printed while [FirebaseLogConfig.enabled] is false.
abstract final class FirebaseLogger {
  static int _sequence = 0;

  /// Placeholder for values that are never printed, whatever the config says.
  static const String secret = '***';

  /// Times [action] and logs its start and outcome.
  ///
  /// [args] is rendered inside the parentheses of the call, [describeResult]
  /// turns the returned value into the short summary of the success line.
  static Future<T> trace<T>(
    String scope,
    String method,
    Future<T> Function() action, {
    Map<String, Object?>? args,
    String Function(T value)? describeResult,
  }) async {
    if (!FirebaseLogConfig.enabled) return action();

    final id = ++_sequence;
    final watch = Stopwatch()..start();
    _print(id, scope, '→ ${_signature(method, args)}');

    try {
      final value = await action();
      watch.stop();
      _print(id, scope, '✓ $method  ${watch.elapsedMilliseconds}ms  ${describeResult?.call(value) ?? 'ok'}');
      return value;
    } catch (error) {
      watch.stop();
      _print(id, scope, '✗ $method  ${watch.elapsedMilliseconds}ms  ${describe(error)}');
      rethrow;
    }
  }

  /// [trace] for the synchronous reads, `isSignedIn` and `getCurrentUser`.
  ///
  /// A single line is enough here, there is no waiting to report.
  static T traceSync<T>(
    String scope,
    String method,
    T Function() action, {
    Map<String, Object?>? args,
    String Function(T value)? describeResult,
  }) {
    if (!FirebaseLogConfig.enabled) return action();

    final id = ++_sequence;
    try {
      final value = action();
      _print(id, scope, '• ${_signature(method, args)}  ${describeResult?.call(value) ?? 'ok'}');
      return value;
    } catch (error) {
      _print(id, scope, '✗ ${_signature(method, args)}  ${describe(error)}');
      rethrow;
    }
  }

  /// Logs a call that is deliberately not awaited, so there is no outcome to
  /// report later.
  static void traceDetached(String scope, String method, {Map<String, Object?>? args}) {
    if (!FirebaseLogConfig.enabled) return;
    _print(++_sequence, scope, '→ ${_signature(method, args)}  (fire and forget)');
  }

  /// Reports a failure that happens outside a call, currently only the Firebase
  /// initialisation that `main` swallows.
  static void failure(String scope, String message, Object error) {
    if (!FirebaseLogConfig.enabled) return;
    _print(++_sequence, scope, '✗ $message  ${describe(error)}');
  }

  static void _print(int id, String scope, String message) {
    debugPrint('[FB#$id][$scope] $message');
  }

  static String _signature(String method, Map<String, Object?>? args) {
    if (args == null || args.isEmpty) return '$method()';
    final rendered = args.entries.map((entry) => '${entry.key}: ${entry.value}').join(', ');
    return '$method($rendered)';
  }

  /// Renders an error with its Firebase code when it carries one, that code is
  /// the part worth reading.
  static String describe(Object error) {
    if (error is FirebaseException) return '${error.runtimeType}(${error.code})';
    return '$error';
  }

  // --- redaction -----------------------------------------------------------

  /// `ahmed@gmail.com` → `a***@gmail.com`.
  static String email(String? value) {
    if (value == null || value.isEmpty) return 'null';
    if (FirebaseLogConfig.payloads) return value;

    final at = value.indexOf('@');
    if (at <= 0) return secret;
    return '${value[0]}$secret${value.substring(at)}';
  }

  /// Shortens uids and document ids, they are noise at full length.
  static String id(String? value) {
    if (value == null || value.isEmpty) return 'null';
    if (FirebaseLogConfig.payloads || value.length <= 6) return value;
    return '${value.substring(0, 6)}…';
  }

  /// Never prints an id token, only whether one came back and how long it is.
  static String token(String? value) {
    if (value == null || value.isEmpty) return 'no token';
    return 'token(len:${value.length})';
  }

  /// A document payload: its size only, unless [FirebaseLogConfig.payloads] is
  /// on and the actual shape is what is being debugged.
  static String document(Map<String, dynamic> json) {
    if (FirebaseLogConfig.payloads) return '$json';
    return 'fields=${json.length}';
  }
}
