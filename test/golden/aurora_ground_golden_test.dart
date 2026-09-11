@Tags(['golden'])
library;

import 'package:algorithm_visualizer/core/widgets/custom_widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/golden_harness.dart';

/// Surfaces 7-9 of contracts/golden-inventory.md, both themes — 6 goldens.
/// Surface 9 (glass.grouped.list) is the R3 acceptance golden proving
/// grouped blur is visually identical to separate blurs (SC-007).
void main() {
  for (final brightness in Brightness.values) {
    final suffix = brightness == Brightness.dark ? 'dark' : 'light';

    testWidgets('aurora.ground.$suffix', (tester) async {
      await pumpGolden(
        tester,
        const AuroraGround(child: SizedBox.expand()),
        brightness: brightness,
      );
      await expectGolden(tester, find.byType(AuroraGround), 'aurora.ground.$suffix');
    });

    testWidgets('glass.on.aurora.$suffix', (tester) async {
      await pumpGolden(
        tester,
        AuroraGround(
          child: Center(
            child: GlassContainer(
              child: const SizedBox(width: 220, height: 120, child: Text('On aurora')),
            ),
          ),
        ),
        brightness: brightness,
      );
      await expectGolden(tester, find.byType(AuroraGround), 'glass.on.aurora.$suffix');
    });

    testWidgets('glass.grouped.list.$suffix', (tester) async {
      await pumpGolden(
        tester,
        AuroraGround(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: GlassContainer(
                  durationForAnimation: const Duration(milliseconds: 200),
                  child: SizedBox(width: 260, height: 80, child: Text('Card $i')),
                ),
              ),
            ),
          ),
        ),
        brightness: brightness,
      );
      await expectGolden(tester, find.byType(AuroraGround), 'glass.grouped.list.$suffix');
    });
  }
}
