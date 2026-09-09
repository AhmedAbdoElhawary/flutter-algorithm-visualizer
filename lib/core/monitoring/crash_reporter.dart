import 'package:flutter/foundation.dart';

/// Vendor-agnostic front door for crash and error reporting.
///
/// App code calls [CrashReporter.instance], never a Sentry type directly —
/// that keeps the vendor swappable and the app testable without a real
/// Sentry DSN. [bootstrap] installs the real implementation
/// ([SentryCrashReporter]) once `SentryFlutter.init` has run; until then (and
/// in `flutter test`, which never boots Sentry) [instance] is a no-op that
/// only prints in debug mode, via [DebugCrashReporter].
abstract class CrashReporter {
  static CrashReporter instance = const DebugCrashReporter();

  /// Reports a caught error. [fatal] marks it as a crash rather than a
  /// recovered/non-fatal error in the dashboard.
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    bool fatal = false,
    Map<String, Object?>? context,
  });

  /// Leaves a breadcrumb — one line of "what the user was doing" that shows
  /// up in the trail leading up to the next reported error.
  void addBreadcrumb(String message, {String? category});

  /// Tags reported errors with who hit them, once auth exists. No email/PII —
  /// an opaque id only.
  void setUserId(String? id);
}

/// Default implementation: prints through [FirebaseLogger]'s conventions
/// instead of vanishing. Used before Sentry is initialized and in tests.
class DebugCrashReporter implements CrashReporter {
  const DebugCrashReporter();

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    bool fatal = false,
    Map<String, Object?>? context,
  }) async {
    if (!kDebugMode) return;
    debugPrint('[Crash]${fatal ? '[FATAL]' : ''} $error');
    if (context != null && context.isNotEmpty) debugPrint('[Crash] context: $context');
    if (stackTrace != null) debugPrint('$stackTrace');
  }

  @override
  void addBreadcrumb(String message, {String? category}) {
    if (!kDebugMode) return;
    debugPrint('[Crash][breadcrumb]${category != null ? '[$category]' : ''} $message');
  }

  @override
  void setUserId(String? id) {
    if (!kDebugMode) return;
    debugPrint('[Crash] user set to ${id ?? 'null'}');
  }
}
