import 'dart:ui';

import 'package:algorithm_visualizer/core/flavor/flavor.dart';
import 'package:algorithm_visualizer/core/flavor/flavor_config.dart';
import 'package:algorithm_visualizer/core/monitoring/analytics_service.dart';
import 'package:algorithm_visualizer/core/monitoring/crash_reporter.dart';
import 'package:algorithm_visualizer/core/monitoring/monitoring.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes/recording_crash_reporter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const withDsn = FlavorConfig(
    flavor: Flavor.production,
    appName: 'AlgoDive',
    apiBaseUrl: '',
    sentryDsn: 'https://key@sentry.example/1',
  );

  late RecordingCrashReporter reporter;

  setUp(() {
    reporter = RecordingCrashReporter();
    CrashReporter.instance = reporter;
  });

  tearDown(Monitoring.debugReset);

  test('monitoring only runs in a release build', () {
    expect(Monitoring.isEnabled, kReleaseMode);
  });

  test('outside release, start runs the app in a zone that reports what escapes it as fatal', () async {
    var ran = false;

    await Monitoring.start(
      config: withDsn,
      appRunner: () async {
        ran = true;
        Future<void>.error(StateError('lost async error'));
      },
    );
    await pumpEventQueue();

    expect(ran, isTrue);
    expect(reporter.errors.single.error, isA<StateError>());
    expect(reporter.errors.single.fatal, isTrue);
  });

  test('outside release, activate turns nothing on, even with a DSN and Firebase ready', () async {
    await Monitoring.activate(config: withDsn, firebaseReady: false);

    expect(CrashReporter.instance, same(reporter));
    expect(AnalyticsService.instance, isA<DebugAnalyticsService>());
    expect(Monitoring.navigatorObservers, isEmpty);
  });

  test('the observer list cannot be changed from outside', () {
    expect(() => Monitoring.navigatorObservers.add(NavigatorObserver()), throwsUnsupportedError);
  });

  group('the error handlers', () {
    late FlutterExceptionHandler? originalFlutterHandler;
    late ErrorCallback? originalPlatformHandler;

    setUp(() {
      originalFlutterHandler = FlutterError.onError;
      originalPlatformHandler = PlatformDispatcher.instance.onError;
      Monitoring.installErrorHandlers();
    });

    tearDown(() {
      FlutterError.onError = originalFlutterHandler;
      PlatformDispatcher.instance.onError = originalPlatformHandler;
    });

    test('a build or layout error is reported as fatal, with the library it came from', () {
      final originalPresent = FlutterError.presentError;
      FlutterError.presentError = (_) {};
      addTearDown(() => FlutterError.presentError = originalPresent);

      FlutterError.onError!(
        FlutterErrorDetails(exception: StateError('layout'), library: 'rendering library'),
      );

      expect(reporter.errors.single.fatal, isTrue);
      expect(reporter.errors.single.context, {'library': 'rendering library'});
    });

    test('a platform error is reported as fatal and marked handled', () {
      final handled = PlatformDispatcher.instance.onError!(StateError('native'), StackTrace.empty);

      expect(handled, isTrue);
      expect(reporter.errors.single.error, isA<StateError>());
      expect(reporter.errors.single.fatal, isTrue);
    });
  });

  test('debugReset puts the debug services back', () {
    Monitoring.debugReset();

    expect(CrashReporter.instance, isA<DebugCrashReporter>());
    expect(AnalyticsService.instance, isA<DebugAnalyticsService>());
  });
}
