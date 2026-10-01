import 'package:algorithm_visualizer/core/widgets/custom_widgets/secondary_button_quiet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows its label and takes taps', (tester) async {
    var taps = 0;
    await pumpApp(tester, SecondaryButtonQuiet(label: 'Reset', onPressed: () => taps++));

    await tester.tap(find.text('Reset'));

    expect(taps, 1);
  });

  testWidgets('fills the width by default', (tester) async {
    await pumpApp(tester, Center(child: SecondaryButtonQuiet(label: 'Reset', onPressed: () {})));

    expect(tester.getSize(find.byType(SecondaryButtonQuiet)).width, ScreenSize.phone.width);
  });

  testWidgets('in a row, it can hug its label and leave the rest to a neighbour', (tester) async {
    final button = SecondaryButtonQuiet(label: 'Reset', onPressed: () {}, expand: false);
    await pumpApp(tester, Row(children: [button, const Expanded(child: SizedBox(height: 10))]));

    expect(tester.getSize(find.byType(SecondaryButtonQuiet)).width, lessThan(ScreenSize.phone.width / 2));
  });
}
