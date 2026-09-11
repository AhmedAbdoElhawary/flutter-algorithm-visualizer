import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Solved / Accuracy / Attempts, Profile stats, celebration stats. A glass card
/// with a big value over a small label. [emphasis] renders the value in white on
/// a stronger hairline (the celebration "+40 XP" tile); [mono] sets the value in
/// the mono face (times / complexity).
class StatTile extends StatelessWidget {
  final String value;
  final String label;
  final String? sub;
  final bool emphasis;
  final bool mono;

  const StatTile({
    super.key,
    required this.value,
    required this.label,
    this.sub,
    this.emphasis = false,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      depth: GlassDepth.card,
      borderRadius: CdRadius.lg,
      padding: REdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          BoldText(
            value,
            color: emphasis ? ThemeEnum.solidWhite : ThemeEnum.textPrimary,
            fontSize: 19,
            fontFamily: mono ? FontConstants.fontJetBrainsMono : null,
          ),
          const RSizedBox(height: 3),
          RegularText(label, color: ThemeEnum.textSecond, fontSize: 10),
          if (sub != null) ...[
            const RSizedBox(height: 2),
            RegularText(sub!, color: ThemeEnum.textDisabled, fontSize: 10),
          ],
        ],
      ),
    );
  }
}

/// "Activity", "Topics", "This week" — a title row with optional trailing meta.
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SemiBoldText(title, color: ThemeEnum.textPrimary, fontSize: 13),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}
