import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/helper/problem_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each difficulty has its own colour; none is neutral', () {
    expect(ProblemDifficulty.values.map(ProblemStyle.difficultyColor), [
      ThemeEnum.track,
      ThemeEnum.dataEasy,
      ThemeEnum.dataMedium,
      ThemeEnum.dataHard,
    ]);
  });

  test('the description colours match, with none as the target colour', () {
    expect(ProblemDifficulty.values.map(ProblemStyle.difficultyCodeDescriptionColor), [
      ThemeEnum.dataTarget,
      ThemeEnum.dataEasy,
      ThemeEnum.dataMedium,
      ThemeEnum.dataHard,
    ]);
  });

  test('each status has a colour and icon; no status looks untouched', () {
    expect(ProblemStyle.getStatus(ProblemStatus.solved), (ThemeEnum.dataEasy, Icons.check_circle_outline_rounded));
    expect(ProblemStyle.getStatus(ProblemStatus.attempted), (ThemeEnum.dataMedium, Icons.error_outline_rounded));
    expect(ProblemStyle.getStatus(ProblemStatus.none), (ThemeEnum.track, Icons.radio_button_unchecked_rounded));
    expect(ProblemStyle.getStatus(null), (ThemeEnum.track, Icons.radio_button_unchecked_rounded));
  });
}
