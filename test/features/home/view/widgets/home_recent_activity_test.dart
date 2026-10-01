import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/problem_page.dart';
import 'package:algorithm_visualizer/features/home/view/widgets/home_recent_activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';
import '../../../../helpers/screen_matrix.dart';
import 'home_test_problems.dart';

void main() {
  testScreenMatrix('hidden with no submissions', (tester, variant) async {
    await pumpApp(
      tester,
      const HomeRecentActivity(),
      overrides: [problemsOverride([])],
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );

    expect(find.text(StringsManager.recentActivity), findsNothing);
  });

  testScreenMatrix('shows at most five, a very long name without overflow', (tester, variant) async {
    await pumpApp(
      tester,
      const SingleChildScrollView(child: HomeRecentActivity()),
      overrides: [
        problemsOverride([
          submitted(1, ago: const Duration(seconds: 10), name: longName),
          for (var id = 2; id <= 6; id++) submitted(id, ago: Duration(days: id)),
        ]),
      ],
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );

    expect(find.text(StringsManager.recentActivity), findsOneWidget);
    expect(find.text(longName), findsOneWidget);
    expect(find.text('Problem 6'), findsNothing, reason: 'the oldest of six is cut');
  });

  testWidgets('newest first, with a readable time for each', (tester) async {
    await pumpApp(
      tester,
      const SingleChildScrollView(child: HomeRecentActivity()),
      overrides: [
        problemsOverride([
          submitted(5, ago: const Duration(days: 3)),
          submitted(1, ago: const Duration(seconds: 10)),
          submitted(4, ago: const Duration(days: 1, hours: 2)),
          submitted(2, ago: const Duration(minutes: 5)),
          submitted(3, ago: const Duration(hours: 2)),
        ]),
      ],
    );

    final names = [for (var id = 1; id <= 5; id++) 'Problem $id'];
    final tops = [for (final name in names) tester.getTopLeft(find.text(name)).dy];
    expect(tops, [...tops]..sort());

    expect(find.text(StringsManager.justNow), findsOneWidget);
    expect(find.text('5${StringsManager.mAgo}'), findsOneWidget);
    expect(find.text('2${StringsManager.hAgo}'), findsOneWidget);
    expect(find.text(StringsManager.yesterday), findsOneWidget);
    expect(find.text('3${StringsManager.dAgo}'), findsOneWidget);
  });

  testWidgets('tapping an item opens that problem', (tester) async {
    await pumpApp(
      tester,
      const SizedBox(),
      overrides: [
        problemsOverride([submitted(9, ago: Duration.zero, solved: true)]),
      ],
      initialRoute: Routes.home.path,
    );
    await tester.pump();

    final item = find.text('Problem 9');
    await tester.scrollUntilVisible(
      item,
      200,
      scrollable: find.byWidgetPredicate(
        (widget) => widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
    );
    await tester.ensureVisible(item);
    await tester.pumpAndSettle();
    await tester.tap(item);
    await tester.pumpAndSettle();

    expect(tester.widget<ProblemPage>(find.byType(ProblemPage)).problemId, 9);
  });
}
