import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/config/themes/app_theme.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/similar_question.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/problem_page.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/problem_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'support/problem_page_test_support.dart';

// `pushProblem` is the single entry point every "open this problem" tap goes
// through. These tests use a shell shaped like production - the problem branch
// at `Routes.problemBranchIndex`, other tabs around it - to check that a tap
// from a different tab lands in the problem branch, stacks there, and hands the
// user back to the tab they started from once the chain is popped.
void main() {
  Future<GoRouter> pumpShell(WidgetTester tester, List<CodingProblem> problems) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => Scaffold(
            body: shell,
            bottomNavigationBar: Text('branch ${shell.currentIndex}'),
          ),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => Center(
                    child: TextButton(
                      onPressed: () => context.pushProblem('1'),
                      child: const Text('Open from home'),
                    ),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/filler', builder: (context, state) => const Text('Filler')),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.problem.path,
                  name: Routes.problem.name,
                  builder: (context, state) => const Text('Problem branch root'),
                  routes: [
                    GoRoute(
                      path: Routes.subProblem.path,
                      name: Routes.subProblem.name,
                      builder: (context, state) {
                        final id = int.tryParse(state.uri.queryParameters['problem_id'] ?? '') ?? -1;
                        return ProblemPage(problemId: id, showBackButton: false);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );

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
        overrides: [problemsProvider.overrideWithBuild((ref, notifier) => AsyncValue.data(problems))],
        child: ScreenUtilInit(
          designSize: surfaceSize,
          builder: (context, _) => MaterialApp.router(theme: AppTheme.light, routerConfig: router),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  Future<void> solveSimilar(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(Tab, StringsManager.similarQuestions));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ProblemTile));
    await tester.pumpAndSettle();
    await tester.tap(find.text(StringsManager.solveWithArrow));
    await tester.pumpAndSettle();
  }

  testWidgets('a problem opened from another tab lands in the problem branch', (tester) async {
    await pumpShell(tester, [buildTestProblem(problemId: 1, name: 'Problem 1')]);

    expect(find.text('branch 0'), findsOneWidget);

    await tester.tap(find.text('Open from home'));
    await tester.pumpAndSettle();

    expect(find.text('Problem 1'), findsOneWidget);
    expect(find.text('branch ${Routes.problemBranchIndex}'), findsOneWidget);
  });

  testWidgets('further problems stack in the problem branch, not in the tab they came from', (tester) async {
    await pumpShell(tester, [
      buildTestProblem(
        problemId: 1,
        name: 'Problem 1',
        similarQuestions: const [SimilarQuestion(problemId: 2, name: 'Problem 2', reason: 'r')],
      ),
      buildTestProblem(problemId: 2, name: 'Problem 2'),
    ]);

    await tester.tap(find.text('Open from home'));
    await tester.pumpAndSettle();
    await solveSimilar(tester);

    expect(find.text('Problem 2'), findsOneWidget);
    expect(find.text('branch ${Routes.problemBranchIndex}'), findsOneWidget);
  });

  testWidgets('popping the last problem returns to the tab the user started from', (tester) async {
    final router = await pumpShell(tester, [
      buildTestProblem(
        problemId: 1,
        name: 'Problem 1',
        similarQuestions: const [SimilarQuestion(problemId: 2, name: 'Problem 2', reason: 'r')],
      ),
      buildTestProblem(problemId: 2, name: 'Problem 2'),
    ]);

    await tester.tap(find.text('Open from home'));
    await tester.pumpAndSettle();
    await solveSimilar(tester);

    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('Problem 1'), findsOneWidget);
    expect(find.text('branch ${Routes.problemBranchIndex}'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
  });

  testWidgets('re-opening the problem already on screen does nothing', (tester) async {
    final router = await pumpShell(tester, [
      buildTestProblem(
        problemId: 1,
        name: 'Problem 1',
        similarQuestions: const [SimilarQuestion(problemId: 1, name: 'Problem 1', reason: 'r')],
      ),
    ]);

    await tester.tap(find.text('Open from home'));
    await tester.pumpAndSettle();
    final depth = router.routerDelegate.currentConfiguration.matches.length;

    await solveSimilar(tester);

    expect(router.routerDelegate.currentConfiguration.matches.length, depth);
    expect(find.byType(ProblemPage), findsOneWidget);
  });
}
