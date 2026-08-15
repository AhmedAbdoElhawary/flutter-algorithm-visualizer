import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AlgoTab extends ConsumerWidget {
  const AlgoTab({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.addEndPadding,
    this.verticalPadding = 0,
    super.key,
  });
  final String label;
  final bool isSelected;
  final bool addEndPadding;
  final IconData? icon;
  final double verticalPadding;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: REdgeInsets.only(right: addEndPadding ? 8 : 0),
      padding: REdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? context.getColor(ThemeEnum.accentBg) : context.getColor(ThemeEnum.card),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? context.getColor(ThemeEnum.borderAccent) : context.getColor(ThemeEnum.border),
        ),
      ),
      child: Padding(
        padding: REdgeInsets.symmetric(horizontal: 10, vertical: verticalPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              CustomIcon(icon!, color: isSelected ? ThemeEnum.accent : ThemeEnum.hover, size: 20),
              RSizedBox(width: 5)
            ],
            BoldText(
              label,
              textAlign: TextAlign.center,
              fontFamily: FontConstants.fontJetBrainsMono,
              color: isSelected ? ThemeEnum.accent : ThemeEnum.hover,
              fontSize: 13,
            ),
          ],
        ),
      ),
    );
  }
}
