import 'package:algorithm_visualizer/core/resources/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CrashReporter {
  static CrashReporter instance = const DebugCrashReporter();

  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    bool fatal = false,
    Map<String, Object?>? context,
  });

  void addBreadcrumb(String message, {String? category});

  void setUserId(String? id);
}

class SentryCrashReporter implements CrashReporter {
  const SentryCrashReporter();

  @override
  Future<void> recordError(
      Object error,
      StackTrace? stackTrace, {
        bool fatal = false,
        Map<String, Object?>? context,
      }) async {
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: context == null ? null : (scope) => scope.setContexts('error_context', context),
    );
  }

  @override
  void addBreadcrumb(String message, {String? category}) {
    Sentry.addBreadcrumb(Breadcrumb(message: message, category: category));
  }

  @override
  void setUserId(String? id) {
    Sentry.configureScope((scope) {
      scope.setUser(id == null ? null : SentryUser(id: id));
    });
  }
}

class SentryEventCap {
  SentryEventCap({this.maxPerErrorType = 3});

  final int maxPerErrorType;
  final Map<String, int> _seen = {};

  SentryEvent? call(SentryEvent event, Hint hint) {
    final key = event.throwable?.runtimeType.toString() ?? event.exceptions?.firstOrNull?.type ?? 'unknown';
    final count = (_seen[key] ?? 0) + 1;
    _seen[key] = count;
    return count > maxPerErrorType ? null : event;
  }
}

class DebugCrashReporter implements CrashReporter {
  const DebugCrashReporter();

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    bool fatal = false,
    Map<String, Object?>? context,
  }) async {
    if (!kCustomDebugMode) return;
    debugPrint('[Crash]${fatal ? '[FATAL]' : ''} $error');
    if (context != null && context.isNotEmpty) debugPrint('[Crash] context: $context');
    if (stackTrace != null) debugPrint('$stackTrace');
  }

  @override
  void addBreadcrumb(String message, {String? category}) {
    if (!kCustomDebugMode) return;
    debugPrint('[Crash][breadcrumb]${category != null ? '[$category]' : ''} $message');
  }

  @override
  void setUserId(String? id) {
    if (!kCustomDebugMode) return;
    debugPrint('[Crash] user set to ${id ?? 'null'}');
  }
}
