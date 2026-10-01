import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/problem_page.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/history_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/pump_app.dart';
import '../../../../../helpers/screen_matrix.dart';
import '../../../../../helpers/test_data.dart';
import '../../profile_test_data.dart';

void main() {
  final route = '${Routes.profile.path}/${Routes.recentSubmissions.path}';

  Future<void> openHistory(
    WidgetTester tester,
    List<CodingProblem> list, {
    ScreenSize screen = ScreenSize.phone,
    ThemeMode theme = ThemeMode.light,
    double textScale = 1.0,
  }) async {
    await pumpApp(
      tester,
      const SizedBox(),
      overrides: [problems(list), hintAlreadySeen],
      initialRoute: route,
      screen: screen,
      theme: theme,
      textScale: textScale,
    );
    await tester.pumpAndSettle();
  }

  for (final (label, list) in [('empty', <CodingProblem>[]), ('full', fullProfile())]) {
    testScreenMatrix('$label fits the screen', (tester, variant) async {
      await openHistory(tester, list, screen: variant.screen, theme: variant.theme, textScale: variant.textScale);

      if (list.isNotEmpty) {
        // Open every row, so the attempt tables have to fit too.
        for (final row in find.byType(HistoryRow).evaluate().toList()) {
          await tester.ensureVisible(find.byWidget(row.widget));
          await tester.tap(find.byWidget(row.widget), warnIfMissed: false);
          await tester.pumpAndSettle();
        }
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('no practice says so', (tester) async {
    await openHistory(tester, [buildTestProblem()]);

    expect(find.text(StringsManager.noProblemsFound), findsOneWidget);
  });

  testWidgets('one row per practised problem, newest first', (tester) async {
    await openHistory(tester, fullProfile());

    final names = tester.widgetList<HistoryRow>(find.byType(HistoryRow)).map((row) => row.entry.problemName).toList();
    // The first two were both last tried today, so either may come first.
    expect(names.take(2), unorderedEquals(['Valid Parentheses', longProblemName]));
    expect(names.last, 'Two Sum');
  });

  testWidgets('tapping a row shows each attempt, tapping again hides them', (tester) async {
    await openHistory(tester, fullProfile());

    await tester.tap(find.text('Two Sum'));
    await tester.pumpAndSettle();
    expect(find.text(StringsManager.passed), findsOneWidget);
    expect(find.text(StringsManager.failed), findsOneWidget);

    await tester.tap(find.text('Two Sum'));
    await tester.pumpAndSettle();
    expect(find.text(StringsManager.passed), findsNothing);
  });

  testWidgets('a long press opens the problem', (tester) async {
    await openHistory(tester, fullProfile());

    await tester.longPress(find.text('Two Sum'));
    await tester.pumpAndSettle();

    expect(find.byType(ProblemPage), findsOneWidget);
  });
}
