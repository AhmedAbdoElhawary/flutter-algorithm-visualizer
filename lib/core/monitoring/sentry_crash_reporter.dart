import 'package:algorithm_visualizer/core/monitoring/crash_reporter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Real [CrashReporter], backed by the Sentry SDK that [SentryFlutter.init]
/// already started in `bootstrap.dart`. Only ever constructed once a DSN is
/// present — see `FlavorConfig.sentryDsn`.
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
      withScope: context == null
          ? null
          : (scope) => scope.setContexts('app', context),
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

/// Free-plan quota guard for [SentryOptions.beforeSend].
///
/// Sentry bills per **event**, not per issue — the dashboard still shows one
/// card ("seen 1,240 times · 312 users") no matter how many events fed it,
/// but the free 5k-events/month allowance is spent per event. This caps how
/// many times the *same* error type is sent from one app session, so one
/// user's crash loop cannot burn a large share of the quota, without
/// touching `sampleRate` — sampling would drop real users from the "N users
/// affected" count, which is the number that actually matters.
class SentryEventCap {
  SentryEventCap({this.maxPerErrorType = 3});

  final int maxPerErrorType;
  final Map<String, int> _seen = {};

  /// Wire this into `SentryFlutterOptions.beforeSend` at init time. Returns
  /// null (drop) once [maxPerErrorType] has been hit for this error's
  /// `runtimeType` in the current app session.
  SentryEvent? call(SentryEvent event, Hint hint) {
    final key = event.throwable?.runtimeType.toString() ?? event.exceptions?.firstOrNull?.type ?? 'unknown';
    final count = (_seen[key] ?? 0) + 1;
    _seen[key] = count;
    return count > maxPerErrorType ? null : event;
  }
}
