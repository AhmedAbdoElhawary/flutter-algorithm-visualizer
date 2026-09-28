import 'package:algorithm_visualizer/core/widgets/custom_widgets/bottom_cta_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('holds its button, and the button still takes taps', (tester) async {
    var taps = 0;
    await pumpApp(
      tester,
      Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: BottomCtaBar(child: TextButton(onPressed: () => taps++, child: const Text('Start'))),
        ),
      ),
    );

    await tester.tap(find.text('Start'));

    expect(taps, 1);
  });
}
