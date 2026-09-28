import 'package:algorithm_visualizer/core/widgets/custom_widgets/primary_button_quiet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows its label and takes taps', (tester) async {
    var taps = 0;
    await pumpApp(tester, PrimaryButtonQuiet(label: 'Run', onPressed: () => taps++));

    await tester.tap(find.text('Run'));

    expect(taps, 1);
  });

  testWidgets('while loading, it spins and ignores taps', (tester) async {
    var taps = 0;
    await pumpApp(tester, PrimaryButtonQuiet(label: 'Run', onPressed: () => taps++, loading: true));

    await tester.tap(find.byType(PrimaryButtonQuiet));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Run'), findsNothing);
    expect(taps, 0);
  });

  testWidgets('with no action, it is dimmed', (tester) async {
    await pumpApp(tester, const PrimaryButtonQuiet(label: 'Run', onPressed: null));

    final box = tester.widget<Container>(
      find.descendant(of: find.byType(PrimaryButtonQuiet), matching: find.byType(Container)).first,
    );
    expect((box.decoration! as BoxDecoration).color!.a, closeTo(0.5, 0.01));
  });

  testWidgets('in a row, it can hug its label instead of filling the row', (tester) async {
    final button = PrimaryButtonQuiet(label: 'Run', onPressed: () {}, expand: false);
    await pumpApp(tester, Row(children: [button, const Expanded(child: SizedBox(height: 10))]));

    expect(tester.getSize(find.byType(PrimaryButtonQuiet)).width, lessThan(ScreenSize.phone.width / 2));
  });
}
