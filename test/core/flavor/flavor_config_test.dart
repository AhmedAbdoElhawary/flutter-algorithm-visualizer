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

  group('fromEnvironment, with no --dart-define as in tests', () {
    test('uses the fallback flavor and the default app name', () {
      final config = FlavorConfig.fromEnvironment();

      expect(config.flavor, Flavor.dev);
      expect(config.appName, 'AlgoDive');
      expect(config.apiBaseUrl, isEmpty);
      expect(config.sentryDsn, isEmpty, reason: 'no DSN means Sentry stays off');
    });

    for (final flavor in Flavor.values) {
      test('a ${flavor.name} fallback is honoured', () {
        expect(FlavorConfig.fromEnvironment(fallbackFlavor: flavor).flavor, flavor);
      });
    }
  });
}
