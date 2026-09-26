import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/base/view_model/base_view_model.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/problem_page.dart';
import 'package:algorithm_visualizer/features/home/view/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod/misc.dart' show Override;

import '../../../helpers/pump_app.dart';
import '../../../helpers/screen_matrix.dart';
import '../../../helpers/test_data.dart';

final _solved = buildTestProblem(problemId: 1, name: 'Two Sum').copyWith(
  problemStatus: ProblemStatus.solved,
  solutionsStatus: [ProblemSolutionStatusDTO(code: 'x', isCorrect: true, submittedAt: DateTime.now())],
);

final _attempted = buildTestProblem(problemId: 2, name: 'Valid Parentheses').copyWith(
  problemStatus: ProblemStatus.attempted,
  solutionsStatus: [ProblemSolutionStatusDTO(code: 'x', isCorrect: false, submittedAt: DateTime.now())],
);

Override _problems(List<CodingProblem> problems) =>
    problemsProvider.overrideWithBuild((ref, notifier) => AsyncValue.data(problems));

/// The page's own list: the only vertical scrollable. The topic cards hold small horizontal ones.
final _pageScroll = find.byWidgetPredicate(
  (widget) => widget is Scrollable && widget.axisDirection == AxisDirection.down,
);

/// Scrolls [finder] to the top of the page, so it isn't hidden behind the bottom navigation bar.
Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 200, scrollable: _pageScroll);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

String _location(WidgetTester tester) => GoRouter.of(tester.element(find.byType(Navigator).first))
    .routerDelegate
    .currentConfiguration
    .uri
    .toString();

void main() {
  testScreenMatrix('home — empty renders', (tester, variant) async {
    await pumpApp(
      tester,
      const HomePage(),
      overrides: [_problems([])],
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );

    expect(find.text(StringsManager.continueLabel), findsNothing);
    await _scrollTo(tester, find.text(StringsManager.topics));
    expect(find.text(StringsManager.recentActivity), findsNothing);
  });

  testScreenMatrix('home — some progress renders', (tester, variant) async {
    await pumpApp(
      tester,
      const HomePage(),
      overrides: [
        _problems([_solved, _attempted]),
      ],
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );

    await _scrollTo(tester, find.text(StringsManager.continueLabel));
    expect(find.text(_attempted.getName), findsWidgets);
    await _scrollTo(tester, find.text(StringsManager.recentActivity));
  });

  testScreenMatrix('home — guest renders the sign-in link', (tester, variant) async {
    await pumpApp(
      tester,
      const HomePage(),
      overrides: [_problems([])],
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );

    expect(find.text(StringsManager.signIn), findsOneWidget);
  });

  testScreenMatrix('home — signed in renders the user name and no sign-in link', (tester, variant) async {
    final user = buildTestUser();

    await pumpApp(
      tester,
      const HomePage(),
      overrides: [_problems([])],
      signedInAs: user,
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );

    expect(find.textContaining(user.name!), findsOneWidget);
    expect(find.text(StringsManager.signIn), findsNothing);
  });

  group('each topic tile opens its visualizer', () {
    final tiles = {
      for (final card in SortingAlgoCards.values.take(3))
        card.name: BaseViewModel.sortingCards(card).card.algoComplexity.name,
      for (final card in SearchingAlgoCards.values)
        card.name: BaseViewModel.searchingCards(card).card.algoComplexity.name,
    };

    for (final tile in tiles.entries) {
      testWidgets(tile.key, (tester) async {
        await pumpApp(tester, const SizedBox(), overrides: [_problems([])], initialRoute: Routes.home.path);
        await tester.pump();

        await _scrollTo(tester, find.text(tile.value));
        await tester.tap(find.text(tile.value));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(_location(tester), '${Routes.visualize.path}?${Routes.visualize.queryParamsName}=${tile.key}');

        // The visualizer queues its pause for after the frame when it closes; let that run.
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 1));
      });
    }
  });

  testWidgets('the continue card opens that problem', (tester) async {
    await pumpApp(
      tester,
      const SizedBox(),
      overrides: [
        _problems([_solved, _attempted]),
      ],
      initialRoute: Routes.home.path,
    );
    await tester.pump();

    await _scrollTo(tester, find.text(StringsManager.continueLabel));
    await tester.tap(find.text(StringsManager.continueLabel));
    await tester.pumpAndSettle();

    expect(find.byType(ProblemPage), findsOneWidget);
    expect(tester.widget<ProblemPage>(find.byType(ProblemPage)).problemId, _attempted.getProblemId);
  });
}
