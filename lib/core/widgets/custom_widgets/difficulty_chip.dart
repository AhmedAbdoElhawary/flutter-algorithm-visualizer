import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

(ThemeEnum fill, ThemeEnum label) _difficultyRoles(ProblemDifficulty d) => switch (d) {
      ProblemDifficulty.easy => (ThemeEnum.chipEasyFill, ThemeEnum.difficultyEasy),
      ProblemDifficulty.medium => (ThemeEnum.chipMediumFill, ThemeEnum.difficultyMedium),
      ProblemDifficulty.hard => (ThemeEnum.chipHardFill, ThemeEnum.difficultyHard),
      ProblemDifficulty.none => (ThemeEnum.primary, ThemeEnum.primary),
    };

/// Easy / Medium / Hard pill — solid tinted fill, never an alpha wash.
class DifficultyChip extends StatelessWidget {
  final ProblemDifficulty difficulty;
  final String label;
  final double fontSize;
  final double radius;

  const DifficultyChip({
    super.key,
    required this.difficulty,
    required this.label,
    this.fontSize = 10.5,
    this.radius = 9,
  });

  @override
  Widget build(BuildContext context) {
    final (fill, labelRole) = _difficultyRoles(difficulty);
    return Container(
      padding: REdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: context.getColor(fill),
        borderRadius: BorderRadius.circular(radius.r),
      ),
      child: SemiBoldText(label, color: labelRole, fontSize: fontSize),
    );
  }
}

/// A fixed-size square variant — History's difficulty-initial badge ("E" /
/// "M" / "H"). [difficulty] is nullable to cover the domain's `none` case
/// (neutral fill), which [Difficulty] itself has no member for.
class DifficultySquareBadge extends StatelessWidget {
  final ProblemDifficulty? difficulty;
  final String label;
  final double size;
  final double radius;
  final double fontSize;

  const DifficultySquareBadge({
    super.key,
    required this.difficulty,
    required this.label,
    this.size = 28,
    this.radius = 9,
    this.fontSize = 10.5,
  });

  @override
  Widget build(BuildContext context) {
    final d = difficulty;
    final (fill, labelRole) =
        d == null ? (ThemeEnum.chipNeutralFill, ThemeEnum.textSecond) : _difficultyRoles(d);
    return Container(
      width: size.r,
      height: size.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.getColor(fill),
        borderRadius: BorderRadius.circular(radius.r),
      ),
      child: BoldText(label, color: labelRole, fontSize: fontSize),
    );
  }
}
