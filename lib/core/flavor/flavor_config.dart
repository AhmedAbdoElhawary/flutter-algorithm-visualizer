import 'package:algorithm_visualizer/core/flavor/flavor.dart';
import 'package:flutter/foundation.dart';

@immutable
class FlavorConfig {
  const FlavorConfig({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    required this.sentryDsn,
  });

  final Flavor flavor;
  final String appName;
  final String apiBaseUrl;
  final String sentryDsn;

  static FlavorConfig? _instance;

  static void initialize(FlavorConfig config) => _instance ??= config;

  factory FlavorConfig.fromEnvironment({Flavor fallbackFlavor = Flavor.dev}) {
    const rawFlavor = String.fromEnvironment('FLAVOR');
    final flavor = Flavor.values.firstWhere(
      (f) => f.name == rawFlavor,
      orElse: () => fallbackFlavor,
    );
    return FlavorConfig(
      flavor: flavor,
      appName: const String.fromEnvironment(
        'APP_NAME',
        defaultValue: 'AlgoDive',
      ),
      apiBaseUrl: const String.fromEnvironment('API_BASE_URL'),
      sentryDsn: const String.fromEnvironment('SENTRY_DSN'),
    );
  }

  @visibleForTesting
  static void debugReset() => _instance = null;

  @visibleForTesting
  static bool get checkInitialization {
    final config = _instance;
    if (config == null) {
      throw StateError(
        'FlavorConfig has not been initialized. Launch the app through one of '
        'lib/main_dev.dart, lib/main_staging.dart or lib/main_prod.dart.',
      );
    }
    return true;
  }
}
