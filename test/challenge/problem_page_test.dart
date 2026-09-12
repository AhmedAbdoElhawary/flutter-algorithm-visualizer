import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/bottom_cta_bar.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_back_button.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/difficulty_chip.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/problem_page_test_support.dart';

void main() {
  TabController activeController(WidgetTester tester) =>
      tester.widget<TabBar>(find.byType(TabBar)).controller!;

  Future<void> tapTab(WidgetTester tester, String label) async {
    await tester.tap(find.widgetWithText(Tab, label));
    await tester.pumpAndSettle();
  }

  testWidgets('horizontal drag on the tab body moves to the adjacent tab (FR-009)', (tester) async {
    final problem = buildTestProblem(hints: const ['Think about a hash map.']);
    await pumpProblemPage(tester, problem: problem);

    expect(activeController(tester).index, 0);

    await tester.drag(find.byType(TabBarView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(activeController(tester).index, 1);
  });

  testWidgets('tapping each tab label selects that tab (FR-009)', (tester) async {
    final problem = buildTestProblem(hints: const ['Hint one'], similarQuestions: const []);
    await pumpProblemPage(tester, problem: problem);

    await tapTab(tester, StringsManager.hints);
    expect(activeController(tester).index, 1);

    await tapTab(tester, StringsManager.similarQuestions);
    expect(activeController(tester).index, 2);

    await tapTab(tester, StringsManager.problemTab);
    expect(activeController(tester).index, 0);
  });

  testWidgets("a tab's scroll offset survives switching away and back (FR-011)", (tester) async {
    final problem = buildTestProblem(description: buildLongDescription());
    await pumpProblemPage(tester, problem: problem);

    final problemScrollable =
        find.descendant(of: find.byKey(const PageStorageKey('problem-1-problem')), matching: find.byType(Scrollable))
            .first;

    await tester.drag(problemScrollable, const Offset(0, -300));
    await tester.pumpAndSettle();

    final offsetBefore = tester.state<ScrollableState>(problemScrollable).position.pixels;
    expect(offsetBefore, greaterThan(0));

    await tapTab(tester, StringsManager.hints);
    await tapTab(tester, StringsManager.problemTab);

    final offsetAfter = tester.state<ScrollableState>(problemScrollable).position.pixels;
    expect(offsetAfter, offsetBefore);
  });

  testWidgets(
      'deep scroll hides tags/difficulty but keeps back button, title, and tab strip tappable (FR-010/FR-010a)',
      (tester) async {
    final problem = buildTestProblem(description: buildLongDescription());
    await pumpProblemPage(tester, problem: problem);

    expect(find.byType(DifficultyChip), findsOneWidget);

    await tester.drag(find.byType(TabBarView), const Offset(0, -1200));
    await tester.pumpAndSettle();

    expect(find.byType(DifficultyChip), findsNothing);
    expect(find.text(problem.getTags.join(', ')), findsNothing);

    expect(find.byType(CustomBackButton), findsOneWidget);
    expect(find.text(problem.getName), findsOneWidget);
    expect(find.byType(TabBar), findsOneWidget);

    await tapTab(tester, StringsManager.hints);
    expect(activeController(tester).index, 1);
  });

  testWidgets('the pinned CTA stays visible and hit-testable across tabs and at a deep scroll offset (FR-014)',
      (tester) async {
    final problem = buildTestProblem(description: buildLongDescription(), hints: const ['h1']);
    await pumpProblemPage(tester, problem: problem);

    for (final label in [StringsManager.problemTab, StringsManager.hints, StringsManager.similarQuestions]) {
      await tapTab(tester, label);
      expect(find.byType(BottomCtaBar), findsOneWidget);
      expect(tester.getSize(find.byType(BottomCtaBar)).height, greaterThan(0));
    }

    await tapTab(tester, StringsManager.problemTab);
    await tester.drag(find.byType(TabBarView), const Offset(0, -1200));
    await tester.pumpAndSettle();

    expect(find.byType(BottomCtaBar), findsOneWidget);
    expect(tester.getSize(find.byType(BottomCtaBar)).height, greaterThan(0));
  });

  testWidgets('one upward drag from a deep offset restores the full header, including tags (FR-010b)',
      (tester) async {
    final problem = buildTestProblem(description: buildLongDescription());
    await pumpProblemPage(tester, problem: problem);

    await tester.drag(find.byType(TabBarView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    expect(find.byType(DifficultyChip), findsNothing);

    await tester.drag(find.byType(TabBarView), const Offset(0, 1200));
    await tester.pumpAndSettle();

    expect(find.byType(DifficultyChip), findsOneWidget);
  });

  testWidgets('content shorter than the viewport never half-collapses the header (Edge Cases)', (tester) async {
    final problem = buildTestProblem(description: 'One short line.', constraints: const [], examples: const []);
    await pumpProblemPage(tester, problem: problem);

    expect(find.byType(DifficultyChip), findsOneWidget);

    await tester.drag(find.byType(TabBarView), const Offset(0, -1200));
    await tester.pumpAndSettle();

    expect(find.byType(DifficultyChip), findsOneWidget);
  });

  testWidgets('reduce-motion zeroes the tab transition and the header snap (Edge Cases)', (tester) async {
    final problem = buildTestProblem(hints: const ['h1']);
    await pumpProblemPage(tester, problem: problem, disableAnimations: true);

    final appBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
    expect(appBar.snap, isFalse);

    await tester.tap(find.widgetWithText(Tab, StringsManager.hints));
    final controller = activeController(tester);
    expect(controller.index, 1);
    expect(controller.indexIsChanging, isFalse);
  });

  testWidgets('a problem with no hints shows the T039 message, not the word "Hints" (FR-015)', (tester) async {
    final problem = buildTestProblem(hints: const []);
    await pumpProblemPage(tester, problem: problem);

    await tapTab(tester, StringsManager.hints);

    expect(find.text(StringsManager.noHintsYet), findsOneWidget);
  });
}
