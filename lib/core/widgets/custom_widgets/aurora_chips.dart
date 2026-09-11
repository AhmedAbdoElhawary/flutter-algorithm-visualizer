import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The three difficulty levels a chip can carry. Callers map their own domain
/// enum onto this — the chip never takes a colour.
enum ChipDifficulty { easy, medium, hard }

ThemeEnum _difficultyRole(ChipDifficulty d) => switch (d) {
      ChipDifficulty.easy => ThemeEnum.difficultyEasy,
      ChipDifficulty.medium => ThemeEnum.difficultyMedium,
      ChipDifficulty.hard => ThemeEnum.difficultyHard,
    };

/// Easy / Medium / Hard pill — 13% fill of the difficulty hue, the full hue as
/// the label. [radius] defaults to a pill; list contexts pass 6.
class DifficultyChip extends StatelessWidget {
  final ChipDifficulty difficulty;
  final String label;
  final double fontSize;
  final double radius;

  const DifficultyChip({
    super.key,
    required this.difficulty,
    required this.label,
    this.fontSize = 11,
    this.radius = CdRadius.md,
  });

  @override
  Widget build(BuildContext context) {
    final role = _difficultyRole(difficulty);
    final hue = context.getColor(role);
    return Container(
      padding: REdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: hue.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(radius.r),
      ),
      child: SemiBoldText(label, color: role, fontSize: fontSize),
    );
  }
}

/// Neutral tag chip — white 10% fill, [ThemeEnum.textBody] label. Same shape as
/// [DifficultyChip].
class TagChip extends StatelessWidget {
  final String label;
  final double fontSize;
  final double radius;

  const TagChip({
    super.key,
    required this.label,
    this.fontSize = 10,
    this.radius = CdRadius.pill,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: context.getColor(ThemeEnum.primaryTint),
        borderRadius: BorderRadius.circular(radius.r),
      ),
      child: RegularText(label, color: ThemeEnum.textBody, fontSize: fontSize),
    );
  }
}

/// Filter row chip — All / Easy / Med / Hard, algorithm chips. Selected: the hue
/// at 10% fill + 35% border + hue label. Unselected: recessed fill, body label.
class AuroraFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final String? count;
  final ChipDifficulty? difficulty;
  final VoidCallback? onTap;

  const AuroraFilterChip({
    super.key,
    required this.label,
    required this.selected,
    this.count,
    this.difficulty,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final role =
        difficulty == null ? ThemeEnum.primary : _difficultyRole(difficulty!);
    final hue = context.getColor(role);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: REdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? hue.withValues(alpha: 0.10)
              : context.getColor(ThemeEnum.glassRecessedFill),
          borderRadius: BorderRadius.circular(CdRadius.pill.r),
          border: Border.all(
            color: selected
                ? hue.withValues(alpha: 0.35)
                : context.getColor(ThemeEnum.borderSubtle),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SemiBoldText(label,
                color: selected ? role : ThemeEnum.textBody, fontSize: 12),
            if (count != null && count!.isNotEmpty) ...[
              const RSizedBox(width: 5),
              MediumText(count!,
                  color: selected ? role : ThemeEnum.textSecond, fontSize: 11),
            ],
          ],
        ),
      ),
    );
  }
}
