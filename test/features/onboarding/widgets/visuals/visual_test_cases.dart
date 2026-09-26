import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';
import '../../../../helpers/screen_matrix.dart';

/// The checks every onboarding visual shares: run while active, stop when not, hold still with animations off.
///
/// [fillsOnce] is for the heatmap: it's a result, not a loop, so once started it finishes filling and then stops.
void visualTestCases(Widget Function(bool isActive) build, {bool fillsOnce = false}) {
  testScreenMatrix('runs a full animation cycle with no errors', (tester, variant) async {
    await pumpApp(
      tester,
      Center(child: build(true)),
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );

    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }

    expect(tester.takeException(), isNull);
  });

  testWidgets('does not animate while inactive', (tester) async {
    await pumpApp(tester, Center(child: build(false)));

    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets(
      fillsOnce ? 'finishes filling, then stops, when it becomes inactive' : 'stops when it becomes inactive',
      (tester) async {
    final active = ValueNotifier(true);
    addTearDown(active.dispose);
    await pumpApp(
      tester,
      Center(
        child: ValueListenableBuilder(valueListenable: active, builder: (context, value, _) => build(value)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    active.value = false;
    await tester.pump();
    if (fillsOnce) {
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pump(const Duration(seconds: 10));
    }

    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('holds its final frame when animations are turned off', (tester) async {
    await pumpApp(
      tester,
      Center(
        child: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: build(true),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.hasRunningAnimations, isFalse);
  });
}
