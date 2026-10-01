import 'package:algorithm_visualizer/core/widgets/custom_widgets/quiet_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  double filled(WidgetTester tester) =>
      tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox)).widthFactor!;

  for (final (value, expected) in [(0.4, 0.4), (-1.0, 0.0), (3.0, 1.0)]) {
    testWidgets('$value fills $expected of the bar', (tester) async {
      await pumpApp(tester, QuietProgressBar(value: value));

      expect(filled(tester), expected);
    });
  }
}
