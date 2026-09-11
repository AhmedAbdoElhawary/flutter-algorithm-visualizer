import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Category selector, 1× / 2× / 3× speed. A recessed track; the selected
/// segment is a white-10% pill with the sheen, its label in [ThemeEnum
/// .textPrimary]; the rest are [ThemeEnum.textSecond].
class AuroraSegmentedControl<T> extends StatelessWidget {
  final List<AuroraSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;
  final double height;

  const AuroraSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.height = 34,
  });

  @override
  Widget build(BuildContext context) {
    return GlassTrack(
      height: height,
      borderRadius: CdRadius.pill,
      child: Padding(
        padding: REdgeInsets.all(3),
        child: Row(
          children: segments.map((s) {
            final active = s.value == selected;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(s.value),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  alignment: Alignment.center,
                  decoration: active
                      ? BoxDecoration(
                          color: context.getColor(ThemeEnum.primaryTint),
                          borderRadius: BorderRadius.circular(CdRadius.pill.r),
                          border: Border(
                            top: BorderSide(
                                color:
                                    context.getColor(ThemeEnum.glassSheenCard)),
                          ),
                        )
                      : null,
                  child: active
                      ? SemiBoldText(s.label,
                          color: ThemeEnum.textPrimary,
                          fontSize: 12,
                          maxLines: 1)
                      : MediumText(s.label,
                          color: ThemeEnum.textSecond,
                          fontSize: 12,
                          maxLines: 1),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class AuroraSegment<T> {
  final T value;
  final String label;

  const AuroraSegment({required this.value, required this.label});
}
