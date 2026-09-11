import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The activity grid — 12 columns, 11px cells, 3.5px gaps, 3px corners.
/// [dailyCounts] is a per-day level already clamped to 0..4; [HeatGrid] and
/// [HeatGridLegend] both index [heatLevels] (Contract 3) so they can never
/// disagree.
class HeatGrid extends StatelessWidget {
  static const List<ThemeEnum> heatLevels = [
    ThemeEnum.heat0,
    ThemeEnum.heat1,
    ThemeEnum.heat2,
    ThemeEnum.heat3,
    ThemeEnum.heat4,
  ];

  final List<int> dailyCounts;

  const HeatGrid({super.key, required this.dailyCounts});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 3.5.w,
      runSpacing: 3.5.h,
      children: dailyCounts
          .map((level) => _HeatCell(level: heatLevels[level.clamp(0, heatLevels.length - 1)]))
          .toList(),
    );
  }
}

/// `Less ▢▢▢▢▢ More` — reads the same [HeatGrid.heatLevels] list the grid
/// cells use; never a second, separately maintained list (FR-016).
class HeatGridLegend extends StatelessWidget {
  const HeatGridLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RegularText(StringsManager.less, color: ThemeEnum.textSecond, fontSize: 11),
        RSizedBox(width: 4),
        Wrap(
          spacing: 3.5.w,
          children: HeatGrid.heatLevels.map((level) => _HeatCell(level: level)).toList(),
        ),
        RSizedBox(width: 4),
        RegularText(StringsManager.more, color: ThemeEnum.textSecond, fontSize: 11),
      ],
    );
  }
}

class _HeatCell extends StatelessWidget {
  const _HeatCell({required this.level});

  final ThemeEnum level;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 11.r,
      height: 11.r,
      decoration: BoxDecoration(
        color: context.getColor(level),
        borderRadius: BorderRadius.circular(3.r),
        border: level == HeatGrid.heatLevels.first
            ? Border.all(color: context.getColor(ThemeEnum.border))
            : null,
      ),
    );
  }
}
