import 'package:algorithm_visualizer/core/flavor/flavor.dart';
import 'package:flutter/foundation.dart';

/// Immutable, runtime view of the values that differ per flavor.
///
/// Populated once at boot from `--dart-define` values (supplied by
/// `dart_define/<flavor>.json` via `--dart-define-from-file`), then read
/// anywhere through [FlavorConfig.instance].
///
/// Nothing here is a real secret — only environment selectors and public
/// endpoints. Native Firebase config files carry the Firebase keys; signing
/// secrets live in `key.properties` / CI secrets, never in Dart.
@immutable
class FlavorConfig {
  const FlavorConfig({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    required this.sentryDsn,
  });

  final Flavor flavor;

  /// User-facing name; mirrors the native app label for the same flavor.
  final String appName;

  /// Base URL every network call is built on top of.
  final String apiBaseUrl;

  /// This flavor's Sentry project DSN. A DSN is a public client key (not a
  /// secret), same as [apiBaseUrl] — safe to commit in `dart_define/<flavor>.json`.
  /// Empty until the three Sentry projects exist; [bootstrap] skips
  /// `SentryFlutter.init` when this is empty so a bare `flutter test` (which
  /// has no defines at all) never tries to reach the network.
  final String sentryDsn;

  /// Show the flavor ribbon / debug label in-app. Off for production.
  bool get showFlavorBanner => !flavor.isProduction;

  static FlavorConfig? _instance;

  /// The config for the running flavor. Throws if an entry point forgot to
  /// call [FlavorConfig.initialize] — that is deliberate, it fails loudly
  /// instead of silently running with the wrong environment.
  static FlavorConfig get instance {
    final config = _instance;
    if (config == null) {
      throw StateError(
        'FlavorConfig has not been initialized. Launch the app through one of '
        'lib/main_dev.dart, lib/main_staging.dart or lib/main_prod.dart.',
      );
    }
    return config;
  }

  static bool get isInitialized => _instance != null;

  static void initialize(FlavorConfig config) => _instance ??= config;

  /// Builds the config from compile-time `--dart-define` values.
  ///
  /// Expects `FLAVOR`, `APP_NAME` and `API_BASE_URL` to be defined (they are,
  /// in `dart_define/<flavor>.json`). Falls back to [fallbackFlavor] only so a
  /// bare `flutter test` without defines still boots.
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
}
