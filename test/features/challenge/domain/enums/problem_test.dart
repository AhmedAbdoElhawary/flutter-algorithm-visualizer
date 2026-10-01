import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each difficulty has its own translatable label, and none means all', () {
    expect(ProblemDifficulty.values.map((d) => d.difficultyString), [
      StringsManager.all,
      StringsManager.easy,
      StringsManager.medium,
      StringsManager.hard,
    ]);
  });

  test('each status has its own translatable label', () {
    expect(ProblemStatus.values.map((s) => s.difficultyString), [
      StringsManager.solvedMoment,
      StringsManager.attempted,
      StringsManager.notSolved,
    ]);
  });
}
