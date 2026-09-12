import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/statistics/profile_statistics_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileHeatmap extends StatelessWidget {
  const ProfileHeatmap({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isThemeDark;

    final heatColors = [
      context.getColor(ThemeEnum.heat0),
      context.getColor(ThemeEnum.heat1),
      context.getColor(ThemeEnum.heat2),
      context.getColor(ThemeEnum.heat3),
    ];

    return HorizontalPadding(
      padding: 16,
      child: Container(
        padding: REdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.getColor(ThemeEnum.card),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.getColor(ThemeEnum.border)),
          boxShadow: context.cardShadow,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const BoldText(StringsManager.activityHeatmap, color: ThemeEnum.textSecond, fontSize: 13),
            Row(children: [
              const RegularText(StringsManager.less, color: ThemeEnum.hoverSecond, fontSize: 11),
              const RSizedBox(width: 4),
              ...heatColors.asMap().entries.map((e) => Container(
                    width: 10.r,
                    height: 10.r,
                    margin: REdgeInsets.only(left: 3),
                    decoration: BoxDecoration(
                      color: e.value,
                      borderRadius: BorderRadius.circular(2),
                      border: e.key == 0 ? Border.all(color: context.getColor(ThemeEnum.border)) : null,
                    ),
                  )),
              const RSizedBox(width: 4),
              const RegularText(StringsManager.more, color: ThemeEnum.hoverSecond, fontSize: 11),
            ]),
          ]),
          const RSizedBox(height: 10),
          Consumer(
            builder: (context, ref, child) {
              final heatmapData = ref.watch(profileStatisticsProvider.select((value) => value.heatmapData));

              return Wrap(
                spacing: 3.r,
                runSpacing: 3.r,
                children: heatmapData
                    .map(
                      (level) => Container(
                        width: 10.r,
                        height: 10.r,
                        decoration: BoxDecoration(
                          color: heatColors[level],
                          borderRadius: BorderRadius.circular(2),
                          border: level == 0
                              ? Border.all(color: context.getColor(ThemeEnum.border), width: 0.5.r)
                              : null,
                          boxShadow: level == 3 && isDark
                              ? [
                                  BoxShadow(
                                      color: context.getColor(ThemeEnum.heat3).withValues(alpha: 0.3),
                                      blurRadius: 4)
                                ]
                              : null,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ]),
      ),
    );
  }
}
