import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view/profile_page.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view/sub_views/bookmarked_problems_page.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view/sub_views/practice_history_page.dart';
import 'package:algorithm_visualizer/features/settings/view/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';
import '../../../../helpers/screen_matrix.dart';
import '../../../../helpers/test_data.dart';
import '../profile_test_data.dart';

void main() {
  Future<void> openProfile(
    WidgetTester tester, {
    bool full = true,
    bool signedIn = true,
    ScreenSize screen = ScreenSize.phone,
    ThemeMode theme = ThemeMode.light,
    double textScale = 1.0,
  }) async {
    await pumpApp(
      tester,
      const SizedBox(),
      overrides: [problems(full ? fullProfile() : []), hintAlreadySeen],
      signedInAs: signedIn ? buildTestUser() : null,
      initialRoute: Routes.profile.path,
      screen: screen,
      theme: theme,
      textScale: textScale,
    );
    await tester.pumpAndSettle();
  }

  final pageScroll = find.descendant(of: find.byType(ProfileScreen), matching: find.byType(Scrollable)).first;

  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(finder, 200, scrollable: pageScroll);
    await tester.pumpAndSettle();
  }

  for (final (label, full, signedIn) in [
    ('empty, as a guest', false, false),
    ('full, signed in', true, true),
    ('full, as a guest', true, false),
  ]) {
    testScreenMatrix('$label fits the screen top to bottom', (tester, variant) async {
      await openProfile(
        tester,
        full: full,
        signedIn: signedIn,
        screen: variant.screen,
        theme: variant.theme,
        textScale: variant.textScale,
      );

      expect(find.text(signedIn ? 'Ada Lovelace' : StringsManager.anonymous), findsOneWidget);
      await scrollTo(tester, find.text(StringsManager.activityHeatmap));
      if (full) await scrollTo(tester, find.text(StringsManager.viewAll));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('empty hides the topics and history cards', (tester) async {
    await openProfile(tester, full: false);

    expect(find.text(StringsManager.solvedTopics), findsNothing);
    expect(find.text(StringsManager.practiceHistory), findsNothing);
  });

  testWidgets('the bookmarks tile opens the bookmarks', (tester) async {
    await openProfile(tester);

    await tester.tap(find.byIcon(Icons.bookmark_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(BookmarkedProblemsPage), findsOneWidget);
  });

  testWidgets('view all opens the practice history', (tester) async {
    await openProfile(tester);
    await scrollTo(tester, find.text(StringsManager.viewAll));

    await tester.tap(find.text(StringsManager.viewAll));
    await tester.pumpAndSettle();

    expect(find.byType(RecentSubmissionsPage), findsOneWidget);
  });

  testWidgets('the gear opens settings', (tester) async {
    await openProfile(tester);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPage), findsOneWidget);
  });
}
