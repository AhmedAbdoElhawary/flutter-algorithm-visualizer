import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/config/themes/app_theme.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/example.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/function_signature.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/similar_question.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/test_case.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/repositories/problem_repository.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/celebration_page.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/editor_page.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/problem_page.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riverpod/misc.dart' show Override;

/// In-memory [ProblemRepository] so `updateProblemSubmission` (called from
/// the editor's run chain, research R5) never touches real local storage or
/// a remote data source during a widget test.
class FakeProblemRepository implements ProblemRepository {
  final List<CodingProblem> updated = [];

  @override
  Future<List<CodingProblem>> getAllProblems() async => [];

  @override
  Future<void> saveProblem(CodingProblem problem) async {}

  @override
  Future<void> updateProblem(CodingProblem problem) async {
    updated.add(problem);
  }

  @override
  Future<void> deleteProblem(int problemId) async {}
}

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

/// Correct solution for [buildGradableTestProblem]'s `int add(int a, int b)`.
const String gradableCorrectCode = 'int add(int a, int b) {\n  return a + b;\n}\n';

/// A wrong solution for the same problem (subtracts instead of adding).
const String gradableWrongCode = 'int add(int a, int b) {\n  return a - b;\n}\n';

/// A real, gradeable problem: `int add(int a, int b)` returning `a + b`,
/// checked against one visible test case — enough to drive the editor's
/// actual on-device interpreter in run/submission tests without a golden
/// file. [code] becomes the pre-filled starting code (`getCode`); pass
/// [gradableCorrectCode] or [gradableWrongCode].
CodingProblem buildGradableTestProblem({
  int problemId = 1,
  String name = 'Add Two Numbers',
  List<TestCase> testCases = const [TestCase(input: 'a=1, b=2', expectedOutput: '3')],
  List<TestCase> hiddenTestCases = const [],
  String code = gradableCorrectCode,
  List<ProblemSolutionStatusDTO> solutionsStatus = const [],
}) {
  return buildTestProblem(problemId: problemId, name: name).copyWith(
    functionSignature: const FunctionSignature(generic: null, dart: 'int add(int a, int b)'),
    defaultCode: {'dart': code},
    testCases: testCases,
    hiddenTestCases: hiddenTestCases,
    solutionsStatus: solutionsStatus,
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

/// Pumps [EditorPage] directly behind a minimal [GoRouter], for tests that
/// only care about the editor's own behaviour (states, running, actions).
///
/// Pass [problemsAsync] directly to drive `getProblemProvider`'s four
/// outcomes (`data-model.md` §1) — loading / error / `data(null)` /
/// `data(problem)` — instead of wrapping a single [problem] in
/// `AsyncValue.data`.
Future<void> pumpEditorPage(
  WidgetTester tester, {
  CodingProblem? problem,
  int? problemId,
  AsyncValue<List<CodingProblem>>? problemsAsync,
  ProblemRepository? repository,
  Size surfaceSize = problemPageSurfaceSize,
  Brightness brightness = Brightness.light,
}) async {
  final resolvedAsync = problemsAsync ?? AsyncValue.data(problem == null ? <CodingProblem>[] : [problem]);

  final overrides = <Override>[
    problemsProvider.overrideWithBuild((ref, notifier) => resolvedAsync),
    if (repository != null) problemRepositoryProvider.overrideWithValue(repository),
  ];

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => EditorPage(problemId: problemId ?? problem?.getProblemId ?? -1),
      ),
      GoRoute(
        path: Routes.celebration.path,
        name: Routes.celebration.name,
        builder: (context, state) => CelebrationPage(args: state.extra! as CelebrationArgs),
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

  await tester.pump();
}

/// Pumps [ProblemPage] behind a router that mirrors production's real
/// `Routes.problem` / `Routes.subProblem` / `Routes.editor` / `Routes.subEditor`
/// nesting (`route-contract.md`), so tapping **Solve in editor** and popping
/// back exercise the exact same navigation shape production uses.
Future<GoRouter> pumpProblemToEditorChain(
  WidgetTester tester, {
  required List<CodingProblem> problems,
  required int rootProblemId,
  ProblemRepository? repository,
  Size surfaceSize = problemPageSurfaceSize,
}) async {
  final overrides = <Override>[
    problemsProvider.overrideWithBuild((ref, notifier) => AsyncValue.data(problems)),
    if (repository != null) problemRepositoryProvider.overrideWithValue(repository),
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
            routes: [
              GoRoute(
                path: Routes.subEditor.path,
                name: Routes.subEditor.name,
                builder: (context, state) {
                  final id = int.tryParse(state.uri.queryParameters['problem_id'] ?? '') ?? -1;
                  return EditorPage(problemId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: Routes.editor.path,
            name: Routes.editor.name,
            builder: (context, state) {
              final id = int.tryParse(state.uri.queryParameters['problem_id'] ?? '') ?? -1;
              return EditorPage(problemId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: Routes.celebration.path,
        name: Routes.celebration.name,
        builder: (context, state) => CelebrationPage(args: state.extra! as CelebrationArgs),
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
