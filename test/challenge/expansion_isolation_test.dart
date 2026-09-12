import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/config/themes/app_theme.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/similar_question.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/challenges_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/bookmark_button.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/problem_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'support/problem_page_test_support.dart';

void main() {
  testWidgets(
      'expanding a page-scoped row (Similar tab shape) does not collapse or expand a '
      'challengesProvider-backed row (Practice list shape) with the same id (FR-022, C2.5d)',
      (tester) async {
    final problem = buildTestProblem(problemId: 5, name: 'Shared Problem');
    late ProviderContainer container;
    var localExpanded = false;

    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.binding.setSurfaceSize(problemPageSurfaceSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [problemsProvider.overrideWithBuild((ref, notifier) => AsyncValue.data([problem]))],
        child: Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return ScreenUtilInit(
              designSize: problemPageSurfaceSize,
              builder: (context, _) => MaterialApp(
                theme: AppTheme.light,
                home: StatefulBuilder(
                  builder: (context, setState) => Scaffold(
                    body: Column(
                      children: [
                        ProblemTile(
                          problemId: 5,
                          expanded: ref.watch(challengesProvider.select((s) => s.expandedId == 5)),
                          onToggle: () => ref.read(challengesProvider.notifier).toggleExpanded(5),
                          onSolveTap: () {},
                        ),
                        ProblemTile(
                          problemId: 5,
                          expanded: localExpanded,
                          onToggle: () => setState(() => localExpanded = !localExpanded),
                          onSolveTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BookmarkButton), findsNothing);

    await tester.tap(find.byType(ProblemTile).last);
    await tester.pumpAndSettle();

    expect(find.byType(BookmarkButton), findsOneWidget);
    expect(container.read(challengesProvider).expandedId, 0);
  });

  testWidgets('two problem pages in one chain hold independent Similar-tab expansions (FR-022, C2.5e)',
      (tester) async {
    final p1 = buildTestProblem(
      problemId: 1,
      name: 'Problem 1',
      similarQuestions: const [SimilarQuestion(problemId: 2, name: 'Problem 2', reason: 'r')],
    );
    final p2 = buildTestProblem(
      problemId: 2,
      name: 'Problem 2',
      similarQuestions: const [SimilarQuestion(problemId: 1, name: 'Problem 1', reason: 'r')],
    );

    final router = await pumpProblemPageChain(tester, problems: [p1, p2], rootProblemId: 1);

    await tester.tap(find.widgetWithText(Tab, StringsManager.similarQuestions));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ProblemTile));
    await tester.pumpAndSettle();
    expect(find.byType(BookmarkButton), findsOneWidget);

    await tester.tap(find.text(StringsManager.solveWithArrow));
    await tester.pumpAndSettle();

    expect(find.text('Problem 2'), findsOneWidget);
    await tester.tap(find.widgetWithText(Tab, StringsManager.similarQuestions));
    await tester.pumpAndSettle();

    expect(find.byType(BookmarkButton), findsNothing);

    router.pop();
    await tester.pumpAndSettle();

    expect(find.text('Problem 1'), findsOneWidget);
    expect(find.byType(BookmarkButton), findsOneWidget);
  });
}
