import 'package:algorithm_visualizer/core/logging/firebase_log_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// ```
/// [FB#7][auth] → login(email: a***@gmail.com)
/// [FB#7][auth] ✓ login  412ms  uid=x9K2wq
/// [FB#8][firestore] ✗ deleteProblem(id: 14)  90ms  FirebaseException(permission-denied)
/// ```

abstract final class FirebaseLogger {
  static int _sequence = 0;

  /// Placeholder for values that are never printed, whatever the config says.
  static const String secret = '***';

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

  static String describe(Object error) {
    if (error is FirebaseException) return '${error.runtimeType}(${error.code})';
    return '$error';
  }

  /// `ahmed@gmail.com` → `a***@gmail.com`.
  static String email(String? value) {
    if (value == null || value.isEmpty) return 'null';
    if (FirebaseLogConfig.payloads) return value;

    final at = value.indexOf('@');
    if (at <= 0) return secret;
    return '${value[0]}$secret${value.substring(at)}';
  }

  /// Ahmed Abdo => A*** A***
  static String name(String? value) {
    if (value == null || value.isEmpty) return 'null';
    if (FirebaseLogConfig.payloads) return value;

    return value
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0]}$secret')
        .join(' ');
  }

  static String id(String? value) {
    if (value == null || value.isEmpty) return 'null';
    if (FirebaseLogConfig.payloads || value.length <= 6) return value;
    return '${value.substring(0, 6)}…';
  }

  static String document(Map<String, dynamic> json) {
    if (FirebaseLogConfig.payloads) return '$json';
    return 'fields=${json.length}';
  }
}
