import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/sync_hint_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/misc.dart' show Override;

import '../../../helpers/fakes/in_memory_storage.dart';
import '../../../helpers/test_data.dart';

const longProblemName = 'Find the Minimum Number of Operations to Make Every Element of the Array Equal';

ProblemSolutionStatusDTO attempt({required bool passed, int daysAgo = 0}) {
  final now = DateTime.now();
  return ProblemSolutionStatusDTO(
    code: 'x',
    isCorrect: passed,
    // An hour before now, so today's attempts are never in the future.
    submittedAt: DateTime(
      now.year,
      now.month,
      now.day - daysAgo,
      now.hour,
      now.minute,
    ).subtract(const Duration(hours: 1)),
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
