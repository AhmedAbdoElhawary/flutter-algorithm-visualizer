import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The three levels a difficulty chip can carry. Callers map their own domain
/// enum onto this — the chip never takes a colour.
enum Difficulty { easy, medium, hard }

(ThemeEnum fill, ThemeEnum label) _difficultyRoles(Difficulty d) => switch (d) {
      Difficulty.easy => (ThemeEnum.chipEasyFill, ThemeEnum.difficultyEasy),
      Difficulty.medium => (ThemeEnum.chipMediumFill, ThemeEnum.difficultyMedium),
      Difficulty.hard => (ThemeEnum.chipHardFill, ThemeEnum.difficultyHard),
    };

/// Easy / Medium / Hard pill — solid tinted fill, never an alpha wash.
class DifficultyChip extends StatelessWidget {
  final Difficulty difficulty;
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
  final Difficulty? difficulty;
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
