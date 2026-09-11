import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// All / Easy / Med / Hard row, the Visualizer's algorithm-chip row. Selected
/// is `primary tint` fill with `text primary`; unselected is a 1px
/// `border subtle` outline with `text secondary`. Never takes a raw colour —
/// [selected] is the only thing that varies its look.
class FilterChipQuiet extends StatelessWidget {
  final String label;
  final bool selected;
  final String? count;
  final VoidCallback? onTap;

  const FilterChipQuiet({
    super.key,
    required this.label,
    required this.selected,
    this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: REdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? context.getColor(ThemeEnum.primaryTint) : null,
          borderRadius: BorderRadius.circular(999.r),
          border: selected ? null : Border.all(color: context.getColor(ThemeEnum.borderSubtle)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MediumText(label, color: selected ? ThemeEnum.textPrimary : ThemeEnum.textSecond, fontSize: 12),
            if (count != null && count!.isNotEmpty) ...[
              RSizedBox(width: 5),
              MediumText(count!, color: selected ? ThemeEnum.textPrimary : ThemeEnum.textSecond, fontSize: 11),
            ],
          ],
        ),
      ),
    );
  }
}
