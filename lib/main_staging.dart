import 'package:algorithm_visualizer/bootstrap.dart';
import 'package:algorithm_visualizer/core/flavor/flavor_config.dart';

/// Staging entry point.
///
/// Run: `flutter run --flavor staging -t lib/main_staging.dart --dart-define-from-file=dart_define/staging.json`
Future<void> main() => bootstrap(FlavorConfig.fromEnvironment());
