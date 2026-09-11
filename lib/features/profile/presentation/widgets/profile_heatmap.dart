import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/glass_card.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/statistics/profile_statistics_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileHeatmap extends StatelessWidget {
  const ProfileHeatmap({super.key});

  /// The five activity steps, low → high. This is the single source of truth:
  /// the legend and the grid both index into it, so they can never disagree.
  static const _heatLevels = [
    ThemeEnum.heat0,
    ThemeEnum.heat1,
    ThemeEnum.heat2,
    ThemeEnum.heat3,
    ThemeEnum.heat4,
  ];

  @override
  Widget build(BuildContext context) {
    return HorizontalPadding(
      padding: 16,
      child: GlassContainer(
        borderRadius: 12,
        padding: REdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const BoldText(StringsManager.activityHeatmap, color: ThemeEnum.textSecond, fontSize: 13),
            Row(children: [
              const RegularText(StringsManager.less, color: ThemeEnum.hoverSecond, fontSize: 11),
              const RSizedBox(width: 4),
              Wrap(
                spacing: 3.r,
                children: _heatLevels.map((level) => _HeatCell(level: level)).toList(),
              ),
              const RSizedBox(width: 4),
              const RegularText(StringsManager.more, color: ThemeEnum.hoverSecond, fontSize: 11),
            ]),
          ]),
          const RSizedBox(height: 10),
          Consumer(
            builder: (context, ref, child) {
              final heatmapData =
                  ref.watch(profileStatisticsProvider.select((value) => value.heatmapData));

              return Wrap(
                spacing: 3.r,
                runSpacing: 3.r,
                children: heatmapData
                    .map((count) =>
                        _HeatCell(level: _heatLevels[count.clamp(0, _heatLevels.length - 1)]))
                    .toList(),
              );
            },
          ),
        ]),
      ),
    );
  }
}

/// One 10x10 square — used identically by the legend and the grid so a swatch
/// and a day cell of the same level render the same. No glow: colour is the
/// only signal, per the Aurora data rules.
class _HeatCell extends StatelessWidget {
  const _HeatCell({required this.level});

  final ThemeEnum level;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10.r,
      height: 10.r,
      decoration: BoxDecoration(
        color: context.getColor(level),
        borderRadius: BorderRadius.circular(2.r),
        border: level == ThemeEnum.heat0
            ? Border.all(color: context.getColor(ThemeEnum.border))
            : null,
      ),
    );
  }
}
