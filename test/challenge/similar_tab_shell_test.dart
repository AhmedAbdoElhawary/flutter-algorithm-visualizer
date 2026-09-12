import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/config/themes/app_theme.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/similar_question.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/problem_page.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/problem_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'support/problem_page_test_support.dart';

// A minimal `StatefulShellRoute.indexedStack` with the real production
// branch shape for `Routes.problem`/`Routes.subProblem` plus a trivial
// second branch, standing in for the full 5-tab `MainNavigationShell` (whose
// other branches pull in Home/Visualize/Profile providers out of scope
// here). This exercises the actual `IndexedStack`-backed branch-preservation
// mechanism go_router uses in production, not a hand-rolled substitute.
void main() {
  testWidgets(
      'the Similar-tab navigation chain and its position survive switching to another '
      'bottom-nav branch and back (FR-018b, C2.6h)', (tester) async {
    final p1 = buildTestProblem(
      problemId: 1,
      name: 'Problem 1',
      similarQuestions: const [SimilarQuestion(problemId: 2, name: 'Problem 2', reason: 'r')],
    );
    final p2 = buildTestProblem(problemId: 2, name: 'Problem 2');

    final problemBranchKey = GlobalKey<NavigatorState>();
    final otherBranchKey = GlobalKey<NavigatorState>();

    final router = GoRouter(
      initialLocation: '${Routes.problem.path}?problem_id=1',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => Scaffold(
            body: shell,
            bottomNavigationBar: Row(
              children: [
                TextButton(onPressed: () => shell.goBranch(0), child: const Text('Problem branch')),
                TextButton(onPressed: () => shell.goBranch(1), child: const Text('Other branch')),
              ],
            ),
          ),
          branches: [
            StatefulShellBranch(
              navigatorKey: problemBranchKey,
              routes: [
                GoRoute(
                  path: Routes.problem.path,
                  name: Routes.problem.name,
                  builder: (context, state) {
                    final id = int.tryParse(state.uri.queryParameters['problem_id'] ?? '') ?? -1;
                    return ProblemPage(problemId: id);
                  },
                  routes: [
                    GoRoute(
                      path: Routes.subProblem.path,
                      name: Routes.subProblem.name,
                      builder: (context, state) {
                        final id = int.tryParse(state.uri.queryParameters['problem_id'] ?? '') ?? -1;
                        return ProblemPage(problemId: id);
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: otherBranchKey,
              routes: [
                GoRoute(path: '/other', builder: (context, state) => const Text('Other tab content')),
              ],
            ),
          ],
        ),
      ],
    );

    GoogleFonts.config.allowRuntimeFetching = false;
    const surfaceSize = problemPageSurfaceSize;
    await tester.binding.setSurfaceSize(surfaceSize);
    tester.view.physicalSize = surfaceSize * problemPageDevicePixelRatio;
    tester.view.devicePixelRatio = problemPageDevicePixelRatio;
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [problemsProvider.overrideWithBuild((ref, notifier) => AsyncValue.data([p1, p2]))],
        child: ScreenUtilInit(
          designSize: surfaceSize,
          builder: (context, _) => MaterialApp.router(theme: AppTheme.light, routerConfig: router),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(Tab, StringsManager.similarQuestions));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ProblemTile));
    await tester.pumpAndSettle();
    await tester.tap(find.text(StringsManager.solveWithArrow));
    await tester.pumpAndSettle();

    expect(find.text('Problem 2'), findsOneWidget);

    await tester.tap(find.text('Other branch'));
    await tester.pumpAndSettle();
    expect(find.text('Other tab content'), findsOneWidget);
    expect(find.text('Problem 2'), findsNothing);

    await tester.tap(find.text('Problem branch'));
    await tester.pumpAndSettle();

    expect(find.text('Problem 2'), findsOneWidget);
  });
}
