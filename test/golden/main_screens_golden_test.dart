@Tags(['golden'])
library;

import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/challenge_page.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/home/view/home_page.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view/profile_page.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/view/visualize_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/misc.dart' show Override;

import 'support/golden_harness.dart';

/// Surfaces 10-14 of contracts/golden-inventory.md — screen.code is SKIPPED:
/// `CodeEditorPage` is entirely commented out in the codebase right now,
/// so there is nothing to capture (documented gap, see RESULTS.md).
/// 4 screens x 2 themes = 8 goldens.
void main() {
  final fixtureProblems = List.generate(
    6,
    (i) => _createProblem(problemId: i + 1, name: 'Problem ${i + 1}', category: 'Arrays'),
  );

  final problemsOverride = problemsProvider.overrideWithBuild(
    (ref, notifier) => AsyncValue.data(fixtureProblems),
  );

  final profileOverride = profileProvider.overrideWithBuild(
    (ref, notifier) => const AsyncValue.data(AuthUser.guest(name: 'Golden Fixture')),
  );

  final overrides = <Override>[problemsOverride, profileOverride];

  for (final brightness in Brightness.values) {
    final suffix = brightness == Brightness.dark ? 'dark' : 'light';

    testWidgets('screen.home.$suffix', (tester) async {
      await pumpGolden(tester, const HomePage(), brightness: brightness, overrides: overrides);
      await expectGolden(tester, find.byType(HomePage), 'screen.home.$suffix');
    });

    testWidgets('screen.visualize.$suffix', (tester) async {
      // The sorting view shuffles its bars with an unseeded Random() on
      // every build — real, intended app behaviour, but it makes the golden
      // non-deterministic. Force a fixed order for the capture only.
      SortingNotifier.debugInitialListOverride = List.generate(
        10,
        (i) => SortableItem(id: i, value: 10 - i),
      );
      addTearDown(() => SortingNotifier.debugInitialListOverride = null);

      await pumpGolden(tester, const VisualizePage(), brightness: brightness, overrides: overrides);
      await expectGolden(tester, find.byType(VisualizePage), 'screen.visualize.$suffix');
    });

    testWidgets('screen.practice.$suffix', (tester) async {
      await pumpGolden(tester, const ChallengePage(), brightness: brightness, overrides: overrides);
      await expectGolden(tester, find.byType(ChallengePage), 'screen.practice.$suffix');
    });

    testWidgets('screen.profile.$suffix', (tester) async {
      // Wider than the standard capture surface: Flutter's built-in test-font
      // placeholder glyphs (used here since no network font fetch is allowed)
      // are wider per-character than the real font, and ProfileHeatmap's
      // header row (activityHeatmap label + legend) overflows at the
      // standard width with those wider glyphs. The real font doesn't
      // overflow here — this is a test-metrics artifact, not a production
      // layout bug, so the fix lives in the capture surface, not the widget.
      await pumpGolden(
        tester,
        const ProfileScreen(),
        brightness: brightness,
        overrides: overrides,
        surfaceSize: const Size(490, 932),
      );
      await expectGolden(tester, find.byType(ProfileScreen), 'screen.profile.$suffix');
    });
  }
}

CodingProblem _createProblem({
  required int problemId,
  required String name,
  required String category,
}) {
  return CodingProblem(
    number: problemId,
    problemId: problemId,
    name: name,
    source: 'Test',
    sourceProblemNumber: problemId,
    difficulty: ProblemDifficulty.easy,
    category: category,
    tags: const [],
    patterns: const [],
    description: 'Test description',
    constraints: const [],
    functionSignature: null,
    defaultCode: null,
    customObjects: null,
    examples: const [],
    edgeCases: const [],
    testCases: const [],
    hiddenTestCases: const [],
    hints: const [],
    solutionApproach: null,
    expectedTimeComplexity: 'O(n)',
    expectedSpaceComplexity: 'O(1)',
    whatYouLearn: 'Testing',
    keyPattern: 'Test pattern',
    prerequisites: const [],
    followUpConcepts: const [],
    commonMistakes: const [],
    similarQuestions: const [],
    problemStatus: ProblemStatus.none,
    isBookmarked: false,
    solutionsStatus: const [],
  );
}
