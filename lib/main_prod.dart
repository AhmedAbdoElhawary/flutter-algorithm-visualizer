import 'package:algorithm_visualizer/bootstrap.dart';
import 'package:algorithm_visualizer/core/flavor/flavor_config.dart';

/// Production entry point.
///
/// Run: `flutter run --flavor production -t lib/main_prod.dart --dart-define-from-file=dart_define/prod.json`
Future<void> main() => bootstrap(FlavorConfig.fromEnvironment());
