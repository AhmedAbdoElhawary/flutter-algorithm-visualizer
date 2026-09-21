import 'dart:async';

import 'package:algorithm_visualizer/core/flavor/flavor_config.dart';
import 'package:algorithm_visualizer/core/monitoring/analytics_service.dart';
import 'package:algorithm_visualizer/core/monitoring/crash_reporter.dart';
import 'package:algorithm_visualizer/core/resources/constants.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract final class Monitoring {
  static const bool isEnabled = kCustomReleaseMode;

  static final List<NavigatorObserver> _navigatorObservers = [];
  static List<NavigatorObserver> get navigatorObservers => List.unmodifiable(_navigatorObservers);

  static Future<void> start({
    required FlavorConfig config,
    required Future<void> Function() appRunner,
  }) async {
    if (!_sentryEnabledFor(config)) {
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

    await SentryFlutter.init(
      (options) => _configure(options, config),
      appRunner: appRunner,
    );
  }

  static void installErrorHandlers() {
    //catches errors during widget build/layout/paint
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      CrashReporter.instance.recordError(
        details.exception,
        details.stack,
        fatal: true,
        context: {'library': details.library ?? 'unknown'},
      );
    };

    //catches native-platform errors.
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      CrashReporter.instance.recordError(error, stackTrace, fatal: true);
      return true;
    };
  }

  static Future<void> activate({
    required FlavorConfig config,
    required bool firebaseReady,
  }) async {
    if (_sentryEnabledFor(config)) {
      CrashReporter.instance = const SentryCrashReporter();
      _navigatorObservers.add(SentryNavigatorObserver());
    }

    if (!firebaseReady) return;

    final analytics = FirebaseAnalytics.instance;
    await analytics.setAnalyticsCollectionEnabled(isEnabled);

    if (!isEnabled) return;
    AnalyticsService.instance = FirebaseAnalyticsService(analytics);
    _navigatorObservers.add(FirebaseAnalyticsObserver(analytics: analytics));
  }

  static bool _sentryEnabledFor(FlavorConfig config) => isEnabled && config.sentryDsn.isNotEmpty;

  static void _configure(SentryFlutterOptions options, FlavorConfig config) {
    options.dsn = config.sentryDsn;
    options.environment = config.flavor.name;

    // don't attach emails, usernames or ip addresses
    options.sendDefaultPii = false;
    options.enableAutoSessionTracking = true;
    options.tracesSampleRate = config.flavor.isProduction ? 0.2 : 1.0;
    options.beforeSend = SentryEventCap().call;
  }

  @visibleForTesting
  static void debugReset() {
    _navigatorObservers.clear();
    CrashReporter.instance = const DebugCrashReporter();
    AnalyticsService.instance = const DebugAnalyticsService();
  }
}
