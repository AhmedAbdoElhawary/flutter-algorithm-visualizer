import 'package:algorithm_visualizer/core/widgets/custom_widgets/algorithm_status_text.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/widgets/linear_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows the step, its progress and its label', (tester) async {
    await pumpApp(
      tester,
      const AlgorithmStatusText(statusText: 'Comparing 3 and 5', progressLabel: '4 / 10', progressValue: 0.4),
    );

    expect(find.text('Comparing 3 and 5'), findsOneWidget);
    expect(find.text('4 / 10'), findsOneWidget);
    final bar = tester.widget<GradientLinearProgressIndicator>(find.byType(GradientLinearProgressIndicator));
    expect(bar.value, 0.4);
  });

  testWidgets('a new label fades in over the old one', (tester) async {
    Widget status(String label) =>
        AlgorithmStatusText(statusText: 'Sorting', progressLabel: label, progressValue: 0.5);
    await pumpApp(tester, status('4 / 10'));

    await pumpApp(tester, status('5 / 10'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('4 / 10'), findsOneWidget);
    expect(find.text('5 / 10'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('4 / 10'), findsNothing);
  });

  testWidgets('a long status fits a small screen with large text', (tester) async {
    await pumpApp(
      tester,
      const AlgorithmStatusText(
        statusText: 'Comparing 38 and 27 — swapping them because 38 is larger',
        progressLabel: '14 / 120',
        progressValue: 0.1,
      ),
      screen: ScreenSize.smallPhone,
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
  });
}
