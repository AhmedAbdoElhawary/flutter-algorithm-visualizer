import 'dart:async';

import 'package:algorithm_visualizer/core/flavor/flavor_config.dart';
import 'package:algorithm_visualizer/core/monitoring/analytics_service.dart';
import 'package:algorithm_visualizer/core/monitoring/crash_reporter.dart';
import 'package:algorithm_visualizer/core/monitoring/sentry_crash_reporter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// The single on/off switch for everything that reports off-device: Sentry
/// (crashes + performance) and Firebase Analytics (usage).
///
/// **Release builds only.** [isEnabled] is `kReleaseMode`, which is false in
/// both debug *and* profile builds, so:
///
/// - running the app locally sends nothing — the error is already in your
///   console, and every event sent would eat the free monthly quota;
/// - a tester's build from Firebase App Distribution reports normally, which
///   is the case that actually matters, because you cannot see their console.
///
/// Note this is deliberately keyed on **build mode**, not flavor: the `dev`
/// flavor built in release mode and handed to a tester *does* report, into
/// its own Sentry project.
///
/// [start] wraps the whole app, so `bootstrap.dart` stays a short list of
/// boot steps instead of a pile of SDK configuration.
abstract final class Monitoring {
  /// Master switch. Release mode only — never debug, never profile.
  static const bool isEnabled = kReleaseMode;

  static final List<NavigatorObserver> _navigatorObservers = [];

  /// Observers the router attaches so screen changes are tracked with no
  /// per-page code. Empty when monitoring is off or a backing SDK failed to
  /// start, so the router never holds a half-initialized observer.
  static List<NavigatorObserver> get navigatorObservers => List.unmodifiable(_navigatorObservers);

  /// Boots crash reporting and runs [appRunner] inside it.
  ///
  /// Both paths run the app inside a [runZonedGuarded] so an async error can
  /// never escape unnoticed; the Sentry path additionally routes it to
  /// Sentry. Sentry is skipped entirely when [isEnabled] is false or this
  /// flavor has no DSN configured yet — the app boots exactly the same way,
  /// it just reports nothing.
  static Future<void> start({
    required FlavorConfig config,
    required Future<void> Function() appRunner,
  }) async {
    Future<void> guarded() {
      final completer = Completer<void>();
      runZonedGuarded(
        () async {
          await appRunner();
          if (!completer.isCompleted) completer.complete();
        },
        (error, stackTrace) => CrashReporter.instance.recordError(error, stackTrace, fatal: true),
      );
      return completer.future;
    }

    if (!_sentryEnabledFor(config)) {
      await guarded();
      return;
    }

    await SentryFlutter.init(
      (options) => _configure(options, config),
      appRunner: guarded,
    );
  }

  /// Installs the Flutter-level error hooks. Called once the binding exists.
  ///
  /// Framework errors (thrown during build/layout/paint) and platform errors
  /// do **not** travel through the zone handler above — Flutter intercepts
  /// them first — so they need their own hooks or they are lost.
  static void installErrorHandlers() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details); // keep the red screen in debug
      CrashReporter.instance.recordError(
        details.exception,
        details.stack,
        fatal: true,
        context: {'library': details.library ?? 'unknown'},
      );
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      CrashReporter.instance.recordError(error, stackTrace, fatal: true);
      return true; // handled — do not also crash the platform side
    };
  }

  /// Swaps the no-op reporters for the real ones and registers the router
  /// observers. Called after `Firebase.initializeApp()` so we know whether
  /// Firebase is actually usable.
  static Future<void> activate({
    required FlavorConfig config,
    required bool firebaseReady,
  }) async {
    if (_sentryEnabledFor(config)) {
      CrashReporter.instance = const SentryCrashReporter();
      _navigatorObservers.add(SentryNavigatorObserver());
    }

    if (!firebaseReady) return;

    // Analytics collection follows the same release-only rule. Calling this
    // explicitly (rather than relying on the default) means a debug run
    // cannot quietly pollute a flavor's real usage numbers.
    final analytics = FirebaseAnalytics.instance;
    await analytics.setAnalyticsCollectionEnabled(isEnabled);

    if (!isEnabled) return;
    AnalyticsService.instance = FirebaseAnalyticsService(analytics);
    _navigatorObservers.add(FirebaseAnalyticsObserver(analytics: analytics));
  }

  /// Sentry needs both the master switch and a DSN for this flavor. Each
  /// flavor points at its own Sentry project — see `dart_define/<flavor>.json`.
  static bool _sentryEnabledFor(FlavorConfig config) => isEnabled && config.sentryDsn.isNotEmpty;

  static void _configure(SentryFlutterOptions options, FlavorConfig config) {
    options.dsn = config.sentryDsn;

    // Tags every event with dev / staging / production. Even with a separate
    // project per flavor this stays worth setting: it makes the environment
    // filter work inside a project, and keeps events meaningful if the
    // projects are ever merged into one.
    options.environment = config.flavor.name;

    // `release` is intentionally not set: sentry_flutter reads the app's own
    // package name + version/build number from the native build. Since each
    // flavor ships a different applicationId suffix (`.dev` / `.staging` /
    // none), that alone already yields distinct release identifiers, and it
    // cannot drift out of sync with pubspec.yaml the way a literal would.

    // Never attach emails, usernames or IP addresses. This app has
    // firebase_auth wired in, so real user emails are in memory — opt out
    // explicitly rather than trusting the default to stay false.
    options.sendDefaultPii = false;

    // Release health: crash-free sessions and crash-free users per release.
    // This is the number worth watching after a production tag ships.
    options.enableAutoSessionTracking = true;

    // Performance: app start time, slow and frozen frames. Full coverage in
    // dev/staging where volume is tiny; a fifth of production traffic, so the
    // free monthly allowance is spent mostly on errors rather than spans.
    options.tracesSampleRate = config.flavor.isProduction ? 0.2 : 1.0;

    // Quota guard — see SentryEventCap. Deliberately not `sampleRate`, which
    // would distort the "N users affected" count.
    options.beforeSend = SentryEventCap().call;
  }

  /// Resets state between tests. Never called by app code.
  @visibleForTesting
  static void debugReset() {
    _navigatorObservers.clear();
    CrashReporter.instance = const DebugCrashReporter();
    AnalyticsService.instance = const DebugAnalyticsService();
  }
}
