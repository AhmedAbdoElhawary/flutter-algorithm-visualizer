import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/widgets/linear_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/pump_app.dart';

void main() {
  Future<double> filled(WidgetTester tester, double value) async {
    await pumpApp(tester, Scaffold(body: GradientLinearProgressIndicator(value: value)));
    return tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox)).widthFactor!;
  }

  testWidgets('fills as far as the value', (tester) async {
    expect(await filled(tester, 0.4), 0.4);
  });

  testWidgets('a value outside 0 to 1 stays inside the rail', (tester) async {
    expect(await filled(tester, -0.5), 0);
    expect(await filled(tester, 1.7), 1);
  });
}
