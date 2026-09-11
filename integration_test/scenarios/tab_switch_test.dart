import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../support/app_driver.dart';
import '../support/perf_harness.dart';
import '../support/perf_report.dart';

/// Taps through all five `StatefulShellBranch` tabs in sequence, recording
/// `tabSwitchMs` per transition (SC-006: under 300ms, zero over-budget
/// frames during the transition).
///
/// See [register] in `scroll_main_screens_test.dart` for why scenario groups
/// share this shape.
void register(List<ScenarioReport> reports) {
  testWidgets('tabswitch.sequence', (tester) async {
    await launchApp(tester);

    for (var i = 0; i < tabLabels.length; i++) {
      final label = tabLabels[i];
      final screen = TargetScreen.values[i]; // TargetScreen order matches tabLabels order exactly.
      final stopwatch = Stopwatch()..start();

      final report = await driveScenario(
        scenarioId: 'tabswitch.sequence.$i.$label',
        screen: screen,
        action: () async {
          await tester.tap(find.text(label));
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        },
      );
      stopwatch.stop();

      reports.add(
        ScenarioReport(
          scenarioId: report.scenarioId,
          screen: report.screen,
          steadyState: report.steadyState,
          warmup: report.warmup,
          tabSwitchMs: stopwatch.elapsedMilliseconds.toDouble(),
        ),
      );
    }
  });
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
