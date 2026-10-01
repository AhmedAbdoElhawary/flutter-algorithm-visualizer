import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/heat_grid.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_heatmap.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';
import '../profile_test_data.dart';

void main() {
  List<int> counts(WidgetTester tester) => tester.widget<HeatGrid>(find.byType(HeatGrid)).dailyCounts;

  testWidgets('no practice shows 12 empty weeks', (tester) async {
    await pumpProfileWidget(tester, const ProfileHeatmap());

    expect(find.text(StringsManager.activityHeatmap), findsOneWidget);
    expect(counts(tester), List.filled(84, 0));
  });

  testWidgets('the last four days light up', (tester) async {
    await pumpProfileWidget(tester, const ProfileHeatmap(), list: fullProfile());

    expect(counts(tester).sublist(79), [0, 1, 1, 1, 1]);
  });

  testWidgets('fits a small screen with large text', (tester) async {
    await pumpProfileWidget(tester, const ProfileHeatmap(),
        list: fullProfile(), screen: ScreenSize.smallPhone, textScale: 2);

    expect(tester.takeException(), isNull);
  });
}
