import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/algorithm_control.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/widgets/control_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/reset.dart';
import '../support/steps.dart';

void sortingJourney() {
  group('sorting', () {
    testWidgets('play, pause, step, then play to the end at full speed', (tester) async {
      await launchApp(tester);
      await skipOnboarding(tester);
      await openTab(tester, StringsManager.visual);
      await pumpUntil(tester, find.text(StringsManager.initialArrayReadyToSort));

      final play = find.byKey(AlgorithmControls.playKey);
      await tapOn(tester, play);
      await tester.pump(const Duration(seconds: 1));
      await tapOn(tester, play);
      await pumpUntil(tester, find.byIcon(Icons.play_arrow_rounded));
      // The label cross-fades, so two copies show for a moment.
      await tester.pump(const Duration(milliseconds: 500));

      final label = _progressLabel(tester);
      await tapOn(tester, find.byKey(AlgorithmControls.forwardKey));
      await tester.pump(const Duration(milliseconds: 500));
      expect(_progressLabel(tester), isNot(label));

      await tapOn(tester, find.text('3×'));
      await tapOn(tester, play);
      await pumpUntil(
        tester,
        find.text(StringsManager.arrayFullySorted),
        timeout: const Duration(minutes: 1),
      );

      // The screen only shows bars, so their left-to-right order is read from the state.
      final controls = find.byType(SortingControlButtons);
      final state = ProviderScope.containerOf(tester.element(controls))
          .read(tester.widget<SortingControlButtons>(controls).notifier);
      double left(SortableItem item) => state.positions[item.id]!.dx;
      final shown = [...state.list]..sort((a, b) => left(a).compareTo(left(b)));
      final values = [for (final item in shown) item.value];
      expect(values, [...values]..sort());

      await tapOn(tester, find.byKey(AlgorithmControls.resetKey));
      await pumpUntil(tester, find.text(StringsManager.initialArrayReadyToSort));
    });
  });
}

/// The "Step N of M" line under the bars.
String? _progressLabel(WidgetTester tester) =>
    tester.widget<Text>(find.textContaining(RegExp(r'^Step \d+ of \d+$'))).data;
