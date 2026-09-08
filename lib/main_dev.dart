import 'package:algorithm_visualizer/bootstrap.dart';
import 'package:algorithm_visualizer/core/flavor/flavor_config.dart';

/// Development entry point.
///
/// Run: `flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=dart_define/dev.json`
Future<void> main() => bootstrap(FlavorConfig.fromEnvironment());
