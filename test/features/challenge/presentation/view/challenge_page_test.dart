import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/loading_state.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/problem_page.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/empty_state.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/error_state.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/problem_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/misc.dart' show Override;

import '../../../../helpers/fakes/fake_problem_repository.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/screen_matrix.dart';
import '../../../../helpers/test_data.dart';

final _problems = [
  buildTestProblem(problemId: 1, name: 'Two Sum', problemStatus: ProblemStatus.solved),
  buildTestProblem(problemId: 2, name: 'Three Sum', difficulty: ProblemDifficulty.medium),
  buildTestProblem(
    problemId: 3,
    name: 'Find the Minimum Number of Operations to Make Every Element of the Array Equal',
    difficulty: ProblemDifficulty.hard,
    tags: const ['Array', 'Math', 'Greedy', 'Sorting', 'Prefix Sum'],
  ),
];

Override _loaded(List<CodingProblem> problems) =>
    problemsProvider.overrideWithBuild((ref, notifier) => AsyncValue.data(problems));

void main() {
  late FakeProblemRepository repository;

  Future<ProviderContainer> openChallenges(
    WidgetTester tester,
    Override problems, {
    ScreenSize screen = ScreenSize.phone,
    ThemeMode theme = ThemeMode.light,
    double textScale = 1.0,
  }) async {
    repository = FakeProblemRepository();
    final container = await pumpApp(
      tester,
      const SizedBox(),
      overrides: [problems, problemRepositoryProvider.overrideWithValue(repository)],
      initialRoute: Routes.practice.path,
      screen: screen,
      theme: theme,
      textScale: textScale,
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    return container;
  }

  final states = {
    'loading': problemsProvider.overrideWithBuild((ref, notifier) => const AsyncValue.loading()),
    'empty': _loaded([]),
    'error': problemsProvider.overrideWithBuild((ref, notifier) => AsyncValue.error(Exception('x'), StackTrace.empty)),
    'list': _loaded(_problems),
  };

  for (final MapEntry(key: label, value: problems) in states.entries) {
    testScreenMatrix('$label fits the screen', (tester, variant) async {
      await openChallenges(tester, problems, screen: variant.screen, theme: variant.theme, textScale: variant.textScale);

      expect(find.text(StringsManager.challenges), findsOneWidget);
      if (label == 'list') {
        await tester.tap(find.byType(ProblemTile).last);
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    });
  }

  for (final (label, body) in [
    ('loading', find.byType(ChallengesLoadingState)),
    ('error', find.byType(ChallengesErrorState)),
    ('empty', find.byType(ChallengesEmptyState)),
    ('list', find.byType(ProblemTile)),
  ]) {
    testWidgets('$label shows its own body', (tester) async {
      await openChallenges(tester, states[label]!);

      expect(body, findsWidgets);
    });
  }

  testWidgets('the header counts solved out of what is shown', (tester) async {
    await openChallenges(tester, _loaded(_problems));
    expect(find.text('1'), findsWidgets);
    expect(find.text('3'), findsWidgets);

    await tester.tap(find.text(StringsManager.hard).first);
    await tester.pumpAndSettle();

    expect(find.byType(ProblemTile), findsOneWidget);
    expect(find.text('0'), findsOneWidget, reason: 'none of the hard ones is solved');
  });

  testWidgets('searching narrows the list, and × clears it', (tester) async {
    await openChallenges(tester, _loaded(_problems));

    await tester.enterText(find.byType(TextField), 'sum ');
    await tester.pumpAndSettle();
    expect(find.byType(ProblemTile), findsNWidgets(2));

    await tester.enterText(find.byType(TextField), 'graph');
    await tester.pumpAndSettle();
    expect(find.byType(ChallengesEmptyState), findsOneWidget);

    await tester.tap(find.text('×'));
    await tester.pumpAndSettle();
    expect(find.byType(ProblemTile), findsNWidgets(3));
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty);
  });

  testWidgets('a card opens, bookmarks, and its solve button opens the problem', (tester) async {
    await openChallenges(tester, _loaded(_problems));

    await tester.tap(find.text('Two Sum'));
    await tester.pumpAndSettle();
    expect(find.text(StringsManager.solveWithArrow), findsOneWidget);

    await tester.tap(find.byIcon(Icons.bookmark_border_rounded));
    await tester.pumpAndSettle();
    expect(repository.updated.single.getIsBookmarked, isTrue);
    expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);

    await tester.tap(find.text(StringsManager.solveWithArrow));
    await tester.pumpAndSettle();
    expect(find.byType(ProblemPage), findsOneWidget);
  });

  testWidgets('opening another card closes the first', (tester) async {
    await openChallenges(tester, _loaded(_problems));

    await tester.tap(find.text('Two Sum'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Three Sum'));
    await tester.pumpAndSettle();

    expect(find.text(StringsManager.solveWithArrow), findsOneWidget);
  });
}
