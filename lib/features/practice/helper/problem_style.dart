import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/features/practice/helper/problem.dart';
import 'package:algorithm_visualizer/lib-temp/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ProblemStyle {
  const ProblemStyle._();

  static Color difficultyColor(BuildContext context, ProblemDifficulty difficulty) {
    switch (difficulty) {
      case ProblemDifficulty.easy:
        return context.getColor(ThemeEnum.accentGreen);
      case ProblemDifficulty.medium:
        return context.getColor(ThemeEnum.accentYellow);
      case ProblemDifficulty.hard:
        return context.getColor(ThemeEnum.accentRed);
      default:
        return context.textVMuted;
    }
  }

  static Color statusColor(BuildContext context, ProblemStatus status) {
    switch (status) {
      case ProblemStatus.solved:
        return context.getColor(ThemeEnum.accentGreen);
      case ProblemStatus.attempted:
        return context.getColor(ThemeEnum.accentYellow);
      default:
        return context.textVMuted;
    }
  }

  static IconData statusIcon(ProblemStatus status) {
    switch (status) {
      case ProblemStatus.solved:
        return Icons.check_circle_outline_rounded;
      case ProblemStatus.attempted:
        return Icons.error_outline_rounded;
      default:
        return Icons.radio_button_unchecked_rounded;
    }
  }
}
