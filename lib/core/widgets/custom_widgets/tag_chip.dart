import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Neutral tag chip — Array, Hash Map, Two Pointers — solid `chipNeutralFill`,
/// `textBody` label. Same shape as [DifficultyChip], no difficulty hue.
class TagChip extends StatelessWidget {
  final String label;
  final double fontSize;
  final double radius;

  const TagChip({super.key, required this.label, this.fontSize = 9.5, this.radius = 6});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: context.getColor(ThemeEnum.chipNeutralFill),
        borderRadius: BorderRadius.circular(radius.r),
      ),
      child: SemiBoldText(label, color: ThemeEnum.textBody, fontSize: fontSize),
    );
  }
}
