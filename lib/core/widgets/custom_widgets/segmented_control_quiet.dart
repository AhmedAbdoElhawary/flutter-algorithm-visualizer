import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The Visualizer's speed selector, the Practice category selector — a 1px
/// `border` group, 3px padding, solid-white selected segment at radius 7.
class SegmentedControlQuiet extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const SegmentedControlQuiet({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.all(6),
      decoration: BoxDecoration(
        color: context.getColor(ThemeEnum.surface),
        borderRadius: BorderRadius.circular(CdRadius.smAlt.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(labels.length, (i) {
          final selected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: Container(
              padding: REdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: selected ? context.getColor(ThemeEnum.raised) : null,
                borderRadius: BorderRadius.circular(CdRadius.segment.r),
              ),
              child: SemiBoldText(
                labels[i],
                color: selected ? ThemeEnum.inkTitle : ThemeEnum.inkSecondaryTitle,
                fontSize: 10,
              ),
            ),
          );
        }),
      ),
    );
  }
}
