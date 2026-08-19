import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:flutter/material.dart';

class ProblemStyle {
  const ProblemStyle._();

  static ThemeEnum difficultyCodeDescriptionColor(ProblemDifficulty difficulty) {
    switch (difficulty) {
      case ProblemDifficulty.easy:
        return ThemeEnum.accentGreen;
      case ProblemDifficulty.medium:
        return ThemeEnum.accentYellow;
      case ProblemDifficulty.hard:
        return ThemeEnum.accentRed;
      case ProblemDifficulty.none:
        return ThemeEnum.accentBlue;
    }
  }

  static ThemeEnum difficultyColor(ProblemDifficulty difficulty) {
    switch (difficulty) {
      case ProblemDifficulty.easy:
        return ThemeEnum.accentGreenRc;
      case ProblemDifficulty.medium:
        return ThemeEnum.accentYellowRc;
      case ProblemDifficulty.hard:
        return ThemeEnum.accentRedRc;
      default:
        return ThemeEnum.hover;
    }
  }

  static (ThemeEnum color, IconData icon) getStatus(ProblemStatus? status) {
    switch (status) {
      case ProblemStatus.solved:
        return (ThemeEnum.accentGreenRc, Icons.check_circle_outline_rounded);
      case ProblemStatus.attempted:
        return (ThemeEnum.accentYellowRc, Icons.error_outline_rounded);
      default:
        return (ThemeEnum.hoverSecond, Icons.radio_button_unchecked_rounded);
    }
  }
}
