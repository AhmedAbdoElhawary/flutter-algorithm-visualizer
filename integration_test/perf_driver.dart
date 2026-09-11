import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'scenarios/scroll_main_screens_test.dart' as scroll_scenarios;
import 'scenarios/sorting_run_test.dart' as sorting_scenarios;
import 'scenarios/tab_switch_test.dart' as tab_switch_scenarios;
import 'support/perf_harness.dart';
import 'support/perf_report.dart';

/// The single entry point `flutter drive --target=integration_test/perf_driver.dart`
/// runs. Combines every scenario group into one on-device pass so
/// `flutter drive` builds and installs the app once instead of once per
/// group, and writes ONE combined [PerformanceBaseline] covering all of
/// them (FR-015, FR-022).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final reports = <ScenarioReport>[];
  scroll_scenarios.register(reports);
  sorting_scenarios.register(reports);
  tab_switch_scenarios.register(reports);

  tearDownAll(() async {
    if (reports.isEmpty) return;
    await writePerformanceBaseline(label: BaselineLabel.before, reports: reports, device: 'oppo-a5i');
  });
}
