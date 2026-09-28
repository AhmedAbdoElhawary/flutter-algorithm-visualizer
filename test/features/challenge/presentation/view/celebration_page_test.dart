import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/celebration_page.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/challenge_page.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/pump_app.dart';
import '../../../../helpers/screen_matrix.dart';
import '../../../../helpers/test_data.dart';

void main() {
  const args = CelebrationArgs(problemName: 'Two Sum', passedCount: 15);

  /// Opens the challenges tab, then celebrates on top of it, as the editor does after a pass.
  Future<void> celebrate(
    WidgetTester tester, {
    ScreenSize screen = ScreenSize.phone,
    ThemeMode theme = ThemeMode.light,
    double textScale = 1.0,
    bool reduceMotion = false,
  }) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: reduceMotion);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpApp(
      tester,
      const SizedBox(),
      overrides: [
        problemsProvider.overrideWithBuild((ref, notifier) => AsyncValue.data([buildTestProblem()])),
      ],
      initialRoute: Routes.practice.path,
      screen: screen,
      theme: theme,
      textScale: textScale,
    );
    await tester.pumpAndSettle();
    GoRouter.of(tester.element(find.byType(ChallengePage))).pushNamed(Routes.celebration.name, extra: args);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
  }

  testScreenMatrix('fits the screen', (tester, variant) async {
    await celebrate(tester, screen: variant.screen, theme: variant.theme, textScale: variant.textScale);

    expect(find.text(StringsManager.solvedMoment), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('names the problem and how many cases passed', (tester) async {
    await celebrate(tester);

    expect(
      find.text(
        'Two Sum · ${StringsManager.allNTestsPassedPrefix}15${StringsManager.allNTestsPassedSuffix}',
      ),
      findsOneWidget,
    );
  });

  testWidgets('the entrance finishes; only the rings keep turning', (tester) async {
    await celebrate(tester);

    final buttons = find.text(StringsManager.nextProblem);
    final fade = tester.widget<FadeTransition>(find.ancestor(of: buttons, matching: find.byType(FadeTransition)).first);
    expect(fade.opacity.value, 1);
  });

  testWidgets('with reduced motion, everything shows at once and nothing moves', (tester) async {
    await celebrate(tester, reduceMotion: true);
    await tester.pumpAndSettle();

    expect(find.text(StringsManager.nextProblem), findsOneWidget);
  });

  testWidgets('"see the visual trace" goes back to where it came from', (tester) async {
    await celebrate(tester);

    await tester.tap(find.text(StringsManager.seeTheVisualTrace));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(CelebrationPage), findsNothing);
    expect(find.byType(ChallengePage), findsOneWidget);
  });

  testWidgets('"next problem" lands on the challenges list, with the celebration gone', (tester) async {
    await celebrate(tester);

    await tester.tap(find.text(StringsManager.nextProblem));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(CelebrationPage), findsNothing);
    expect(find.byType(ChallengePage), findsOneWidget);
  });
}
