import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/config/themes/app_theme.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/example.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/similar_question.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/problem_page.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riverpod/misc.dart' show Override;

const Size problemPageSurfaceSize = Size(430, 932);
const double problemPageDevicePixelRatio = 3.0;

CodingProblem buildTestProblem({
  int problemId = 1,
  String name = 'Two Sum',
  ProblemDifficulty difficulty = ProblemDifficulty.easy,
  List<String> tags = const ['Array', 'Hash Map'],
  String description = 'Given an array of integers, return indices of the two numbers.',
  List<String> constraints = const ['1 <= n <= 10^4'],
  List<Example> examples = const [],
  List<String> hints = const [],
  List<SimilarQuestion> similarQuestions = const [],
}) {
  return CodingProblem(
    number: problemId,
    problemId: problemId,
    name: name,
    source: 'Test',
    sourceProblemNumber: problemId,
    difficulty: difficulty,
    category: 'Arrays',
    tags: tags,
    patterns: const [],
    description: description,
    constraints: constraints,
    functionSignature: null,
    defaultCode: null,
    customObjects: null,
    examples: examples,
    edgeCases: const [],
    testCases: const [],
    hiddenTestCases: const [],
    hints: hints,
    solutionApproach: null,
    expectedTimeComplexity: 'O(n)',
    expectedSpaceComplexity: 'O(1)',
    whatYouLearn: 'Testing',
    keyPattern: 'Test pattern',
    prerequisites: const [],
    followUpConcepts: const [],
    commonMistakes: const [],
    similarQuestions: similarQuestions,
    problemStatus: ProblemStatus.none,
    isBookmarked: false,
    solutionsStatus: const [],
  );
}

/// A long description forces the Problem tab to overflow the viewport, so
/// header-collapse tests have something to scroll past.
String buildLongDescription() => List.generate(60, (i) => 'Line $i of a very long problem description.')
    .join('\n');

/// Pumps [ProblemPage] behind a minimal [GoRouter] (`CustomBackButton` reads
/// `context.canPop()`, which needs a real `GoRouter` ancestor) and a fixed
/// [problemPageSurfaceSize] so ScreenUtil resolves deterministically.
Future<void> pumpProblemPage(
  WidgetTester tester, {
  required CodingProblem problem,
  int? problemId,
  bool disableAnimations = false,
  Size surfaceSize = problemPageSurfaceSize,
  Brightness brightness = Brightness.light,
  List<CodingProblem> extraProblems = const [],
}) async {
  final overrides = <Override>[
    problemsProvider.overrideWithBuild((ref, notifier) => AsyncValue.data([problem, ...extraProblems])),
  ];

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: disableAnimations),
          child: ProblemPage(problemId: problemId ?? problem.getProblemId),
        ),
      ),
    ],
  );

  GoogleFonts.config.allowRuntimeFetching = false;

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
      overrides: overrides,
      child: ScreenUtilInit(
        designSize: surfaceSize,
        minTextAdapt: true,
        builder: (context, _) => MaterialApp.router(
          title: StringsManager.appName,
          debugShowCheckedModeBanner: false,
          theme: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
          routerConfig: router,
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

/// Pumps [ProblemPage] behind a router that mirrors production's nested
/// `Routes.problem` / `Routes.subProblem` shape (a child route on the same
/// navigator), so `context.pushRoute(Routes.subProblem, ...)` stacks a real
/// page and `context.back()` pops it, without needing the full bottom-nav
/// shell.
Future<GoRouter> pumpProblemPageChain(
  WidgetTester tester, {
  required List<CodingProblem> problems,
  required int rootProblemId,
  Size surfaceSize = problemPageSurfaceSize,
}) async {
  final overrides = <Override>[
    problemsProvider.overrideWithBuild((ref, notifier) => AsyncValue.data(problems)),
  ];

  final router = GoRouter(
    initialLocation: '${Routes.problem.path}?problem_id=$rootProblemId',
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
  );

  GoogleFonts.config.allowRuntimeFetching = false;

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
      overrides: overrides,
      child: ScreenUtilInit(
        designSize: surfaceSize,
        minTextAdapt: true,
        builder: (context, _) => MaterialApp.router(
          title: StringsManager.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          routerConfig: router,
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
  return router;
}
