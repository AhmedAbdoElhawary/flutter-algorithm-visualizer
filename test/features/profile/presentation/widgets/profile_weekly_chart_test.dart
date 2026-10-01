import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/bar_chart_quiet.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_weekly_chart.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_data.dart';
import '../profile_test_data.dart';

void main() {
  List<QuietBar> bars(WidgetTester tester) => tester.widgetList<QuietBar>(find.byType(QuietBar)).toList();

  testWidgets('an empty week shows seven short bars and nothing solved', (tester) async {
    await pumpProfileWidget(tester, const ProfileWeeklyChart());

    expect(find.text('0 solved'), findsOneWidget);
    expect(bars(tester).map((bar) => bar.height), everyElement(4.0));
  });

  testWidgets('today counts only passed attempts, and its bar is highlighted', (tester) async {
    await pumpProfileWidget(
      tester,
      const ProfileWeeklyChart(),
      list: [
        buildTestProblem(
          solutions: [attempt(passed: true), attempt(passed: true), attempt(passed: false)],
        ),
      ],
    );

    expect(find.text('2 solved'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    final today = bars(tester)[DateTime.now().weekday - 1];
    expect(today.fill, ThemeEnum.dataEasy);
    expect(today.height, 50.0);
  });

  testWidgets('fits a small screen with large text', (tester) async {
    await pumpProfileWidget(tester, const ProfileWeeklyChart(),
        list: fullProfile(), screen: ScreenSize.smallPhone, textScale: 2);

    expect(find.text(StringsManager.thisWeek), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
