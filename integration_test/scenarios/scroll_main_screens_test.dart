import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../support/app_driver.dart';
import '../support/perf_budgets.dart';
import '../support/perf_harness.dart';
import '../support/perf_report.dart';

/// One 10-second continuous scroll pass per screen (SC-001). `scroll.code`
/// is SKIPPED — `CodeEditorPage` is entirely commented out right now, so
/// there is no screen to scroll (documented gap, same as the golden suite).
///
/// [register] is shared with `integration_test/perf_driver.dart` so this
/// file's scenarios can run either standalone (`main` below) or combined
/// with every other scenario group in one `flutter drive` pass, both
/// contributing to the same [reports] list / baseline file.
void register(List<ScenarioReport> reports) {
  testWidgets('scroll.home', (tester) async {
    await launchApp(tester);
    final report = await driveScenario(
      scenarioId: 'scroll.home',
      screen: TargetScreen.home,
      action: () => continuousScroll(
        tester,
        find.byType(Scrollable).first,
        duration: const Duration(seconds: scrollPassDurationSec),
      ),
    );
    reports.add(report);
  });

  testWidgets('scroll.visualize', (tester) async {
    await launchApp(tester);
    await goToTab(tester, tabLabels[1]);
    final report = await driveScenario(
      scenarioId: 'scroll.visualize',
      screen: TargetScreen.visualize,
      action: () => continuousScroll(
        tester,
        find.byType(Scrollable).first,
        duration: const Duration(seconds: scrollPassDurationSec),
      ),
    );
    reports.add(report);
  });

  testWidgets('scroll.practice', (tester) async {
    await launchApp(tester);
    await goToTab(tester, tabLabels[3]);
    final report = await driveScenario(
      scenarioId: 'scroll.practice',
      screen: TargetScreen.practice,
      action: () => continuousScroll(
        tester,
        find.byType(Scrollable).first,
        duration: const Duration(seconds: scrollPassDurationSec),
      ),
    );
    reports.add(report);
  });

  testWidgets('scroll.practice.maxItems', (tester) async {
    // Uses the app's real, current dataset (assets/problems.json — 100
    // problems, verified at spec time) rather than a synthetic larger list:
    // this is the actual maximum a real user encounters today, and it is
    // already comfortably larger than what fits on screen. FR-004 requires
    // the list to stay smooth "regardless of how many problems it contains" —
    // this scenario is the concrete number that claim is checked against.
    await launchApp(tester);
    await goToTab(tester, tabLabels[3]);
    final report = await driveScenario(
      scenarioId: 'scroll.practice.maxItems',
      screen: TargetScreen.practice,
      action: () => continuousScroll(
        tester,
        find.byType(Scrollable).first,
        duration: const Duration(seconds: scrollPassDurationSec),
        distance: 800,
      ),
    );
    reports.add(report);
  });

  testWidgets('scroll.profile', (tester) async {
    await launchApp(tester);
    await goToTab(tester, tabLabels[4]);
    final report = await driveScenario(
      scenarioId: 'scroll.profile',
      screen: TargetScreen.profile,
      action: () => continuousScroll(
        tester,
        find.byType(Scrollable).first,
        duration: const Duration(seconds: scrollPassDurationSec),
      ),
    );
    reports.add(report);
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
