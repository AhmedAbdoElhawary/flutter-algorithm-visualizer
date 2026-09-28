import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/auth/presentation/confirmation_password/view/confirmation_password_page.dart';
import 'package:algorithm_visualizer/features/auth/presentation/forgot_password/view/forgot_password_page.dart';
import 'package:algorithm_visualizer/features/auth/presentation/login/view/login_page.dart';
import 'package:algorithm_visualizer/features/auth/presentation/signup/view/sign_up_page.dart';
import 'package:algorithm_visualizer/features/base/view_model/base_view_model.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/challenge_page.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/editor_page.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/problem_page.dart';
import 'package:algorithm_visualizer/features/home/view/home_page.dart';
import 'package:algorithm_visualizer/features/onboarding/view/onboarding_page.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view/profile_page.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view/sub_views/bookmarked_problems_page.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view/sub_views/practice_history_page.dart';
import 'package:algorithm_visualizer/features/settings/view/settings_page.dart';
import 'package:algorithm_visualizer/features/visualize/view/visualize_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/pump_app.dart';

void main() {
  /// Some pages keep a spinner or a looping hint going, so this waits a fixed time instead of settling.
  Future<void> open(WidgetTester tester, String location) async {
    await pumpApp(tester, const SizedBox(), initialRoute: location);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  /// Leaving the visualizer queues a pause, so it has to run out before the test ends.
  Future<void> leave(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 30));
  }

  group('every address builds its page', () {
    for (final (location, page) in [
      (Routes.onboarding.path, OnboardingPage),
      (Routes.login.path, LoginPage),
      (Routes.signUp.path, SignUpPage),
      (Routes.forgotPassword.path, ForgotPasswordPage),
      (Routes.confirmationPassword.path, ConfirmationPasswordPage),
      (Routes.home.path, HomePage),
      (Routes.visualize.path, VisualizePage),
      (Routes.practice.path, ChallengePage),
      (Routes.problem.path, ProblemPage),
      ('${Routes.problem.path}/editor?problem_id=1', CodeEditorPage),
      ('${Routes.problem.path}/sub?problem_id=1', ProblemPage),
      ('${Routes.problem.path}/sub/editor?problem_id=1', CodeEditorPage),
      (Routes.profile.path, ProfileScreen),
      ('${Routes.profile.path}/recent_submissions', RecentSubmissionsPage),
      ('${Routes.profile.path}/bookmarked', BookmarkedProblemsPage),
      ('${Routes.profile.path}/settings', SettingsPage),
    ]) {
      testWidgets(location, (tester) async {
        await open(tester, location);

        expect(find.byType(page), findsOneWidget);
        expect(tester.takeException(), isNull);
        await leave(tester);
      });
    }
  });

  group('the visualizer opens the algorithm in the address', () {
    testWidgets('a sorting one', (tester) async {
      await open(tester, '${Routes.visualize.path}?instance=${SortingAlgoCards.bubble.name}');

      expect(tester.widget<VisualizePage>(find.byType(VisualizePage)).sortingCard, SortingAlgoCards.bubble);
      await leave(tester);
    });

    testWidgets('a searching one', (tester) async {
      await open(tester, '${Routes.visualize.path}?instance=${SearchingAlgoCards.aStar.name}');

      expect(
        tester.widget<VisualizePage>(find.byType(VisualizePage)).searchingCard,
        SearchingAlgoCards.aStar,
      );
      await leave(tester);
    });

    testWidgets('one that does not exist is an unknown page', (tester) async {
      await open(tester, '${Routes.visualize.path}?instance=bogoSort');

      expect(find.byType(UnknownView), findsOneWidget);
    });
  });

  group('problem ids', () {
    testWidgets('the id in the address reaches the page', (tester) async {
      await open(tester, '${Routes.problem.path}/sub?problem_id=42');

      expect(tester.widget<ProblemPage>(find.byType(ProblemPage).last).problemId, 42);
    });

    testWidgets('an id that is not a number says nothing is selected instead of failing', (tester) async {
      await open(tester, '${Routes.problem.path}/sub?problem_id=abc');

      expect(tester.widget<ProblemPage>(find.byType(ProblemPage).last).problemId, -1);
      expect(find.text(StringsManager.noChallengeSelected), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('an address the app does not know is an unknown page', (tester) async {
    await open(tester, '/no-such-page');

    expect(find.byType(UnknownView), findsOneWidget);
  });

  group('back from a page opened inside a tab returns to that tab', () {
    for (final (location, page, parent) in [
      ('${Routes.profile.path}/settings', SettingsPage, ProfileScreen),
      ('${Routes.profile.path}/bookmarked', BookmarkedProblemsPage, ProfileScreen),
      ('${Routes.profile.path}/recent_submissions', RecentSubmissionsPage, ProfileScreen),
      ('${Routes.problem.path}/sub?problem_id=1', ProblemPage, ProblemPage),
    ]) {
      testWidgets(location, (tester) async {
        await open(tester, location);

        GoRouter.of(tester.element(find.byType(page).last)).pop();
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.byType(parent), findsOneWidget);
      });
    }
  });

  group('the top-level pages have nothing to go back to', () {
    for (final (location, page) in [
      (Routes.home.path, HomePage),
      (Routes.visualize.path, VisualizePage),
      (Routes.practice.path, ChallengePage),
      (Routes.profile.path, ProfileScreen),
    ]) {
      testWidgets(location, (tester) async {
        await open(tester, location);

        expect(GoRouter.of(tester.element(find.byType(page))).canPop(), isFalse);
        await leave(tester);
      });
    }
  });
}
