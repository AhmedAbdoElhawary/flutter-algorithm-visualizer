import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/difficulty_chip.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/problem_page.dart';
import 'package:algorithm_visualizer/features/home/view/widgets/home_continue_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';
import '../../../../helpers/screen_matrix.dart';
import 'home_test_problems.dart';

void main() {
  testScreenMatrix('hidden when there is nothing to continue', (tester, variant) async {
    await pumpApp(
      tester,
      const HomeContinueCard(),
      overrides: [problemsOverride([])],
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );

    expect(find.text(StringsManager.continueLabel), findsNothing);
  });

  testScreenMatrix('shows a very long problem name without overflow', (tester, variant) async {
    await pumpApp(
      tester,
      const HomeContinueCard(),
      overrides: [
        problemsOverride(
            [submitted(1, ago: Duration.zero, name: longName, difficulty: ProblemDifficulty.hard)]),
      ],
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );

    expect(find.text(StringsManager.continueLabel), findsOneWidget);
    expect(find.text(longName), findsOneWidget);
    expect(find.byType(DifficultyChip), findsOneWidget);
  });

  testWidgets('a problem with no difficulty shows no chip', (tester) async {
    await pumpApp(
      tester,
      const HomeContinueCard(),
      overrides: [
        problemsOverride([submitted(1, ago: Duration.zero, difficulty: ProblemDifficulty.none)]),
      ],
    );

    expect(find.text(StringsManager.continueLabel), findsOneWidget);
    expect(find.byType(DifficultyChip), findsNothing);
  });

  testWidgets('tapping it opens that problem', (tester) async {
    await pumpApp(
      tester,
      const SizedBox(),
      overrides: [
        problemsOverride([submitted(7, ago: Duration.zero)]),
      ],
      initialRoute: Routes.home.path,
    );
    await tester.pump();

    await tester.ensureVisible(find.text(StringsManager.continueLabel));
    await tester.tap(find.text(StringsManager.continueLabel));
    await tester.pumpAndSettle();

    expect(tester.widget<ProblemPage>(find.byType(ProblemPage)).problemId, 7);
  });
}
