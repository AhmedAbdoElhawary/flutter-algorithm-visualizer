import 'package:algorithm_visualizer/features/practice/helper/problem.dart';
import 'package:algorithm_visualizer/lib-temp/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ProblemStyle {
  const ProblemStyle._();

  static Color difficultyColor(BuildContext context, ProblemDifficulty difficulty) {
    switch (difficulty) {
      case ProblemDifficulty.easy:
        return context.accentGreen;
      case ProblemDifficulty.medium:
        return context.accentYellow;
      case ProblemDifficulty.hard:
        return context.accentRed;
        default:
          return context.textVMuted;
    }
  }

  static Color statusColor(BuildContext context, ProblemStatus status) {
    switch (status) {
      case ProblemStatus.solved:
        return context.accentGreen;
      case ProblemStatus.attempted:
        return context.accentYellow;
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
