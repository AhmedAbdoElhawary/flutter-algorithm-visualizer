import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/bottom_cta_bar.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/difficulty_chip.dart';
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

  testWidgets('a problem with no hints shows the T039 message, not the word "Hints" (FR-015)', (tester) async {
    final problem = buildTestProblem(hints: const []);
    await pumpProblemPage(tester, problem: problem);

    await tapTab(tester, StringsManager.hints);

    expect(find.text(StringsManager.noHintsYet), findsOneWidget);
  });
}
