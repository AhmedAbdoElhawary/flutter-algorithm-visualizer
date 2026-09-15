import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:flutter/material.dart';

class ProblemStyle {
  const ProblemStyle._();

  static ThemeEnum difficultyCodeDescriptionColor(ProblemDifficulty difficulty) {
    switch (difficulty) {
      case ProblemDifficulty.easy:
        return ThemeEnum.dataEasy;
      case ProblemDifficulty.medium:
        return ThemeEnum.dataMedium;
      case ProblemDifficulty.hard:
        return ThemeEnum.dataHard;
      case ProblemDifficulty.none:
        return ThemeEnum.dataTarget;
    }
  }

  static ThemeEnum difficultyColor(ProblemDifficulty difficulty) {
    switch (difficulty) {
      case ProblemDifficulty.easy:
        return ThemeEnum.dataEasy;
      case ProblemDifficulty.medium:
        return ThemeEnum.dataMedium;
      case ProblemDifficulty.hard:
        return ThemeEnum.dataHard;
      default:
        return ThemeEnum.track;
    }
  }

  static (ThemeEnum color, IconData icon) getStatus(ProblemStatus? status) {
    switch (status) {
      case ProblemStatus.solved:
        return (ThemeEnum.dataEasy, Icons.check_circle_outline_rounded);
      case ProblemStatus.attempted:
        return (ThemeEnum.dataMedium, Icons.error_outline_rounded);
      default:
        return (ThemeEnum.track, Icons.radio_button_unchecked_rounded);
    }
  }
}
