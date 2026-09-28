import 'package:algorithm_visualizer/core/flavor/flavor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each flavor answers yes only to its own check', () {
    expect([Flavor.dev.isDev, Flavor.dev.isStaging, Flavor.dev.isProduction], [true, false, false]);
    expect([Flavor.staging.isDev, Flavor.staging.isStaging, Flavor.staging.isProduction], [false, true, false]);
    expect(
      [Flavor.production.isDev, Flavor.production.isStaging, Flavor.production.isProduction],
      [false, false, true],
    );
  });
}
