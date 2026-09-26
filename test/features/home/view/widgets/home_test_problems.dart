import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/misc.dart' show Override;

import '../../../../helpers/test_data.dart';

const longName = 'Find the Minimum Number of Operations to Make Every Element in the Array Equal';

Override problemsOverride(List<CodingProblem> problems) =>
    problemsProvider.overrideWithBuild((ref, notifier) => AsyncValue.data(problems));

/// A problem with one submission [ago] before now.
CodingProblem submitted(
  int id, {
  required Duration ago,
  String? name,
  bool solved = false,
  ProblemDifficulty difficulty = ProblemDifficulty.easy,
}) {
  return buildTestProblem(problemId: id, name: name ?? 'Problem $id', difficulty: difficulty).copyWith(
    problemStatus: solved ? ProblemStatus.solved : ProblemStatus.attempted,
    solutionsStatus: [
      ProblemSolutionStatusDTO(code: 'x', isCorrect: solved, submittedAt: DateTime.now().subtract(ago)),
    ],
  );
}
