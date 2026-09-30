import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/algorithm_control.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_constants.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/widgets/pf_grid_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/reset.dart';
import '../support/steps.dart';

void searchingJourney() {
  group('searching', () {
    testWidgets('finds a path around drawn walls, and reports none once the end is walled off', (
      tester,
    ) async {
      await launchApp(tester);
      await skipOnboarding(tester);
      await openTab(tester, StringsManager.visual);
      await tapOn(tester, find.text(StringsManager.searching));
      await pumpUntil(tester, _grid);
      await tester.ensureVisible(_grid);
      await tester.pump(const Duration(seconds: 1));

      await _drag(tester, (8, 10), (8, 20));
      await _drag(tester, (kPFStartRow, kPFStartCol), (2, 2));
      await _drag(tester, (kPFEndRow, kPFEndCol), (18, 26));

      // The speed chip steps up on each tap: 2× → 3× → 5× → 10×.
      for (final speed in ['2×', '3×', '5×']) {
        await tapOn(tester, find.text(speed));
      }
      await tapOn(tester, find.byKey(AlgorithmControls.playKey));
      await pumpUntil(
        tester,
        find.textContaining(StringsManager.searchPathFound),
        timeout: const Duration(minutes: 1),
      );

      await tapOn(tester, find.byKey(AlgorithmControls.resetKey));
      // A press next to a marker grabs it, so each stroke starts 2 cells away and draws through the ring.
      await _drag(tester, (17, 23), (17, 29));
      await _drag(tester, (19, 23), (19, 29));
      await _drag(tester, (16, 25), (20, 25));
      await _drag(tester, (16, 27), (20, 27));

      await tapOn(tester, find.byKey(AlgorithmControls.playKey));
      await pumpUntil(tester, find.text(StringsManager.searchNoPath), timeout: const Duration(minutes: 1));
    });
  });
}

/// The grid and its markers are all painted, so cells are reached by position.
final _grid = find.byWidgetPredicate((widget) => widget is CustomPaint && widget.painter is PFGridPainter);

Offset _cell(WidgetTester tester, (int, int) cell) {
  final size = tester.getSize(_grid).width / kPFCols;
  return tester.getTopLeft(_grid) + Offset((cell.$2 + 0.5) * size, (cell.$1 + 0.5) * size);
}

/// Draws walls from an empty cell, or moves a marker when it starts on one.
Future<void> _drag(WidgetTester tester, (int, int) from, (int, int) to) async {
  final gesture = await tester.startGesture(_cell(tester, from));
  await tester.pump();
  await gesture.moveTo(_cell(tester, to));
  await tester.pump();
  await gesture.up();
  await tester.pump(const Duration(milliseconds: 300));
}
