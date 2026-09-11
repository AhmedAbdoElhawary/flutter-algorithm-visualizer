import 'package:algorithm_visualizer/features/visualize/helper/playback_speed.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view/sorting_view.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../support/app_driver.dart';
import '../support/perf_harness.dart';
import '../support/perf_report.dart';

/// A complete sorting run at every [PlaybackSpeed], at the maximum array
/// size, per FR-003 and the widened SC-002.
///
/// Two gaps in the current app, worked around here and documented rather
/// than silently assumed away:
///
/// 1. **Array size is not user-adjustable today.** `_maxSize`/`_minSize`
///    exist in `SortingNotifier` but nothing wires a control to them yet
///    (see the `todo` on that class) — the UI always runs the default
///    10-item list. This scenario reaches the real max (15 items, the
///    constant's current value) via [SortingNotifier.debugInitialListOverride],
///    the same test-only hook the golden suite uses for determinism.
/// 2. **`fast5`/`fast10` are not reachable by tapping the UI.**
///    `SpeedSelector.getPlaybackSpeedsForSorting()` only exposes
///    slow/normal/fast3 as tappable chips. `slow`/`normal`/`fast3` are
///    driven by real taps here; `fast5`/`fast10` call
///    `AlgorithmControlInterface.changeSpeed` directly on the live notifier,
///    reached through the same `ProviderContainer` the widget tree already
///    uses. The frame cost measured is identical either way — only the
///    input path differs from a tap.
const _maxSize = 15; // SortingNotifier._maxSize at spec time.
const _tappableSpeeds = {PlaybackSpeed.slow, PlaybackSpeed.normal, PlaybackSpeed.fast3};

/// See [register] in `scroll_main_screens_test.dart` for why scenario groups
/// share this shape.
void register(List<ScenarioReport> reports) {
  Future<void> setSpeed(WidgetTester tester, PlaybackSpeed speed) async {
    if (_tappableSpeeds.contains(speed)) {
      // The three exposed chips render in PlaybackSpeed enum order
      // (SpeedSelector.getPlaybackSpeedsForSorting: slow, normal, fast3).
      final chipIndex = _tappableSpeeds.toList().indexOf(speed);
      await tester.tap(find.byType(GestureDetector).at(chipIndex));
      await tester.pump();
      return;
    }
    final container = ProviderScope.containerOf(tester.element(find.byType(SortingView)));
    final notifierProvider = (tester.state(find.byType(SortingView)) as dynamic).instance
        as NotifierProvider<SortingNotifier, SortingNotifierState>;
    container.read(notifierProvider.notifier).changeSpeed(speed);
    await tester.pump();
  }

  Future<void> runSpeed(WidgetTester tester, PlaybackSpeed speed) async {
    SortingNotifier.debugInitialListOverride = List.generate(
      _maxSize,
      (i) => SortableItem(id: i, value: _maxSize - i),
    );
    addTearDown(() => SortingNotifier.debugInitialListOverride = null);

    await launchApp(tester);
    await goToTab(tester, tabLabels[1]);
    await setSpeed(tester, speed);

    await tester.tap(find.byIcon(Icons.play_arrow_rounded));

    final report = await driveScenario(
      scenarioId: 'sorting.run.${speed.name}.maxSize',
      screen: TargetScreen.visualize,
      action: () async {
        // Run until the play icon reappears (sort finished -> auto-paused)
        // or a generous ceiling elapses, whichever comes first.
        for (var i = 0; i < 200; i++) {
          await tester.pump(const Duration(milliseconds: 100));
          if (find.byIcon(Icons.play_arrow_rounded).evaluate().isNotEmpty) break;
        }
      },
    );
    reports.add(report);
  }

  for (final speed in PlaybackSpeed.values) {
    testWidgets('sorting.run.${speed.name}.maxSize', (tester) async {
      await runSpeed(tester, speed);
    });
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final reports = <ScenarioReport>[];
  register(reports);
  tearDownAll(() async {
    if (reports.isEmpty) return;
    await writePerformanceBaseline(label: BaselineLabel.before, reports: reports, device: 'oppo-a5i');
  });
}
