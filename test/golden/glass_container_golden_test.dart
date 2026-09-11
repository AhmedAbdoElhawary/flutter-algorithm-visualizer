@Tags(['golden'])
library;

import 'package:algorithm_visualizer/core/widgets/custom_widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/golden_harness.dart';

/// Surfaces 1-6 of contracts/golden-inventory.md, both themes — 12 goldens.
void main() {
  Widget backdrop(Widget child) => Container(
        color: const Color(0xFF2B2E36),
        alignment: Alignment.center,
        child: child,
      );

  for (final brightness in Brightness.values) {
    final suffix = brightness == Brightness.dark ? 'dark' : 'light';

    testWidgets('glass.recessed.$suffix', (tester) async {
      await pumpGolden(
        tester,
        backdrop(
          const GlassContainer(
            depth: GlassDepth.recessed,
            child: SizedBox(width: 200, height: 100, child: Text('Recessed')),
          ),
        ),
        brightness: brightness,
      );
      await expectGolden(tester, find.byType(GlassContainer), 'glass.recessed.$suffix');
    });

    testWidgets('glass.card.$suffix', (tester) async {
      await pumpGolden(
        tester,
        backdrop(
          const GlassContainer(
            child: SizedBox(width: 200, height: 100, child: Text('Card')),
          ),
        ),
        brightness: brightness,
      );
      await expectGolden(tester, find.byType(GlassContainer), 'glass.card.$suffix');
    });

    testWidgets('glass.floating.$suffix', (tester) async {
      await pumpGolden(
        tester,
        backdrop(
          const GlassContainer(
            depth: GlassDepth.floating,
            child: SizedBox(width: 200, height: 100, child: Text('Floating')),
          ),
        ),
        brightness: brightness,
      );
      await expectGolden(tester, find.byType(GlassContainer), 'glass.floating.$suffix');
    });

    testWidgets('glass.card.noTopShadow.$suffix', (tester) async {
      await pumpGolden(
        tester,
        backdrop(
          const GlassContainer(
            allowCardTopShadow: false,
            child: SizedBox(width: 200, height: 100, child: Text('No top shadow')),
          ),
        ),
        brightness: brightness,
      );
      await expectGolden(tester, find.byType(GlassContainer), 'glass.card.noTopShadow.$suffix');
    });

    testWidgets('glass.card.animated.$suffix', (tester) async {
      await pumpGolden(
        tester,
        backdrop(
          GlassContainer(
            durationForAnimation: const Duration(milliseconds: 200),
            child: const SizedBox(width: 200, height: 100, child: Text('Animated')),
          ),
        ),
        brightness: brightness,
      );
      await expectGolden(tester, find.byType(GlassContainer), 'glass.card.animated.$suffix');
    });
  }
}
