import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/problem_page.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/bookmark_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/misc.dart' show Override;

import '../../../../../helpers/pump_app.dart';
import '../../../../../helpers/screen_matrix.dart';
import '../../../../../helpers/test_data.dart';
import '../../profile_test_data.dart';

void main() {
  final route = '${Routes.profile.path}/${Routes.bookmarkedProblems.path}';

  Future<void> openBookmarks(
    WidgetTester tester,
    Override problemsOverride, {
    ScreenSize screen = ScreenSize.phone,
    ThemeMode theme = ThemeMode.light,
    double textScale = 1.0,
  }) async {
    await pumpApp(
      tester,
      const SizedBox(),
      overrides: [problemsOverride, hintAlreadySeen],
      initialRoute: route,
      screen: screen,
      theme: theme,
      textScale: textScale,
    );
    await tester.pump();
  }

  for (final (label, list) in [('empty', <CodingProblem>[]), ('full', fullProfile())]) {
    testScreenMatrix('$label fits the screen', (tester, variant) async {
      await openBookmarks(
        tester,
        problems(list),
        screen: variant.screen,
        theme: variant.theme,
        textScale: variant.textScale,
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('no bookmarks says so', (tester) async {
    await openBookmarks(tester, problems([buildTestProblem()]));

    expect(find.text(StringsManager.noProblemsFound), findsOneWidget);
    expect(find.text('0 problems'), findsOneWidget);
  });

  testWidgets('lists only the bookmarked problems, with the count', (tester) async {
    await openBookmarks(tester, problems(fullProfile()));

    expect(find.byType(BookmarkRow), findsNWidgets(2));
    expect(find.text('2 problems'), findsOneWidget);
    expect(find.text('Valid Parentheses'), findsNothing);
  });

  testWidgets('one bookmark is "1 problem"', (tester) async {
    await openBookmarks(tester, problems([buildTestProblem(isBookmarked: true)]));

    expect(find.text('1 problem'), findsOneWidget);
  });

  testWidgets('shows a spinner while loading', (tester) async {
    await openBookmarks(
      tester,
      problemsProvider.overrideWithBuild((ref, notifier) => const AsyncValue.loading()),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('says so when the problems fail to load', (tester) async {
    await openBookmarks(
      tester,
      problemsProvider.overrideWithBuild((ref, notifier) => AsyncValue.error(Exception('disk'), StackTrace.empty)),
    );

    expect(find.text(StringsManager.notAbleToLoadAnyChallenge), findsOneWidget);
  });

  testWidgets('tapping a bookmark opens the problem', (tester) async {
    await openBookmarks(tester, problems(fullProfile()));

    await tester.tap(find.text('Two Sum'));
    await tester.pumpAndSettle();

    expect(find.byType(ProblemPage), findsOneWidget);
  });
}
