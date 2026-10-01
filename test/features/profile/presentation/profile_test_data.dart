import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/sync_hint_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/misc.dart' show Override;

import '../../../helpers/fakes/in_memory_storage.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/test_data.dart';

const longProblemName = 'Find the Minimum Number of Operations to Make Every Element of the Array Equal';

/// At midnight of its day, so a test run just after midnight can't slip an attempt into yesterday.
ProblemSolutionStatusDTO attempt({required bool passed, int daysAgo = 0}) {
  final now = DateTime.now();
  return ProblemSolutionStatusDTO(
    code: 'x',
    isCorrect: passed,
    submittedAt: DateTime(now.year, now.month, now.day - daysAgo),
  );
}

/// A bit of everything: each difficulty, bookmarks, a problem passed after failing, one never passed, and a long name.
List<CodingProblem> fullProfile() => [
  buildTestProblem(
    problemId: 1,
    name: 'Two Sum',
    category: 'Arrays',
    problemStatus: ProblemStatus.solved,
    isBookmarked: true,
    solutions: [attempt(passed: false, daysAgo: 2), attempt(passed: true, daysAgo: 1)],
  ),
  buildTestProblem(
    problemId: 2,
    name: 'Valid Parentheses',
    difficulty: ProblemDifficulty.medium,
    category: 'Stacks',
    problemStatus: ProblemStatus.solved,
    solutions: [attempt(passed: true)],
  ),
  buildTestProblem(
    problemId: 3,
    name: longProblemName,
    difficulty: ProblemDifficulty.hard,
    category: 'Heaps',
    problemStatus: ProblemStatus.attempted,
    isBookmarked: true,
    solutions: [attempt(passed: false, daysAgo: 3), attempt(passed: false)],
  ),
  buildTestProblem(problemId: 4, name: 'Binary Search'),
];

Override problems(List<CodingProblem> problems) =>
    problemsProvider.overrideWithBuild((ref, notifier) => AsyncValue.data(problems));

/// The hint's border spins forever, so a page showing it never settles.
final hintAlreadySeen = syncHintStoreProvider.overrideWithValue(
  SyncHintStore(InMemoryStorage({SyncHintStore.seenKey: true})),
);

/// Pumps [widget] on its own, on a scrolling page like the profile's.
Future<ProviderContainer> pumpProfileWidget(
  WidgetTester tester,
  Widget widget, {
  List<CodingProblem> list = const [],
  AuthUser? signedInAs,
  ScreenSize screen = ScreenSize.phone,
  double textScale = 1.0,
}) async {
  final container = await pumpApp(
    tester,
    Material(child: SingleChildScrollView(child: widget)),
    overrides: [problems(list), hintAlreadySeen],
    signedInAs: signedInAs,
    screen: screen,
    textScale: textScale,
  );
  await tester.pumpAndSettle();
  return container;
}
