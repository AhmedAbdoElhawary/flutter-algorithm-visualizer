import 'package:algorithm_visualizer/core/flavor/flavor.dart';
import 'package:algorithm_visualizer/core/flavor/flavor_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(FlavorConfig.debugReset);

  FlavorConfig config(Flavor flavor) =>
      FlavorConfig(flavor: flavor, appName: 'AlgoDive ${flavor.name}', apiBaseUrl: '', sentryDsn: '');

  test('before initialize, the check throws and says how to launch', () {
    expect(
      () => FlavorConfig.checkInitialization,
      throwsA(isA<StateError>().having((e) => e.message, 'message', contains('lib/main_dev.dart'))),
    );
  });

  test('after initialize, the check passes', () {
    FlavorConfig.initialize(config(Flavor.dev));

    expect(FlavorConfig.checkInitialization, isTrue);
  });

  test('initializing twice is harmless', () {
    FlavorConfig.initialize(config(Flavor.dev));
    FlavorConfig.initialize(config(Flavor.production));

    expect(FlavorConfig.checkInitialization, isTrue);
  });

  group('fromEnvironment', () {
    // CI and the run scripts pass dart_define/<flavor>.json, a bare `flutter test` passes nothing.
    const definedFlavor = String.fromEnvironment('FLAVOR');

    test('the FLAVOR define wins, and without one the fallback is used', () {
      for (final fallback in Flavor.values) {
        final flavor = FlavorConfig.fromEnvironment(fallbackFlavor: fallback).flavor;

        expect(flavor, definedFlavor.isEmpty ? fallback : Flavor.values.byName(definedFlavor));
      }
    });

    test('the app name falls back to AlgoDive, the rest come from the defines', () {
      final config = FlavorConfig.fromEnvironment();

      expect(config.appName, const String.fromEnvironment('APP_NAME', defaultValue: 'AlgoDive'));
      expect(config.apiBaseUrl, const String.fromEnvironment('API_BASE_URL'));
      expect(config.sentryDsn, const String.fromEnvironment('SENTRY_DSN'));
    });
  });
}
