import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;
  final IconData? icon;
  final String? sub;
  final bool centerTheContent;
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.emphasized = false,
    this.centerTheContent = false,
    this.icon,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final hasHeaderRow = icon != null || (sub != null && sub!.isNotEmpty);
    Widget tile = CardContainer(
      surface: CdSurface.main,
      radius: CdRadius.md,
      padding: REdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: centerTheContent ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasHeaderRow) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (icon != null)
                  Icon(icon, size: 18.r, color: context.getColor(ThemeEnum.inkSecondaryTitle)),
                const Spacer(),
                if (sub != null && sub!.isNotEmpty)
                  Flexible(
                      child:
                          RegularText(sub!, fontSize: 10, color: ThemeEnum.inkSecondaryTitle, maxLines: 1)),
              ],
            ),
            const RSizedBox(height: 6),
          ],
          SemiBoldText(value, fontSize: 19, color: emphasized ? ThemeEnum.inkPrimary : ThemeEnum.inkTitle),
          const RSizedBox(height: 4),
          RegularText(label, fontSize: 10, color: ThemeEnum.inkSecondaryTitle),
        ],
      ),
    );
    if (emphasized) {
      tile = Stack(
        children: [
          tile,
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(CdRadius.md.r),
                  border: Border.all(color: context.getColor(ThemeEnum.track)),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return tile;
  }
}
