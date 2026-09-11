import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Solved / Accuracy / Attempts, Profile stats, celebration stats — an
/// outlined tile with a label under a value. [emphasized] swaps the hairline
/// for `border strong` and the value ink for `textBright` — the one
/// highlighted tile in a row (e.g. celebration's `+40 XP`).
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;
  final IconData? icon;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.emphasized = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: context.getColor(emphasized ? ThemeEnum.borderStrong : ThemeEnum.borderSubtle),
        ),
      ),
      child: Column(
        crossAxisAlignment: icon == null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18.r, color: context.getColor(ThemeEnum.textBody)),
            RSizedBox(height: 4),
          ],
          SemiBoldText(value, fontSize: 19, color: emphasized ? ThemeEnum.textBright : ThemeEnum.textPrimary),
          RSizedBox(height: 4),
          RegularText(label, fontSize: 10, color: ThemeEnum.textSecond, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
