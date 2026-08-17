import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/profile/data/profile_stats_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileHeatmap extends ConsumerWidget {
  const ProfileHeatmap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(profileStatsProvider);
    final isDark = context.isThemeDark;

    final heatColors = isDark
        ? [ColorManager.outputHeaderDk.withValues(alpha: 0.5), const Color.fromRGBO(26, 58, 42, 1), const Color.fromRGBO(30, 92, 58, 1), const Color.fromRGBO(52, 211, 153, 1)]
        : [const Color.fromRGBO(238, 242, 255, 1), const Color.fromRGBO(187, 247, 208, 1), const Color.fromRGBO(134, 239, 172, 1), const Color.fromRGBO(34, 197, 94, 1)];

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
            BoldText(StringsManager.activityHeatmap, color: ThemeEnum.textSecond, fontSize: 13),
            Row(children: [
              RegularText(StringsManager.less, color: ThemeEnum.hoverSecond, fontSize: 11),
              RSizedBox(width: 4),
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
              RSizedBox(width: 4),
              RegularText(StringsManager.more, color: ThemeEnum.hoverSecond, fontSize: 11),
            ]),
          ]),
          RSizedBox(height: 10),
          Wrap(
            spacing: 3.r,
            runSpacing: 3.r,
            children: stats.heatmapData.map((level) => Container(
              width: 10.r,
              height: 10.r,
              decoration: BoxDecoration(
                color: heatColors[level],
                borderRadius: BorderRadius.circular(2),
                border: level == 0 ? Border.all(color: context.getColor(ThemeEnum.border),width: 0.5.r) : null,
                boxShadow: level == 3 && isDark
                    ? [BoxShadow(color: const Color.fromRGBO(52, 211, 153, 1).withValues(alpha: 0.3), blurRadius: 4)]
                    : null,
              ),
            )).toList(),
          ),
        ]),
      ),
    );
  }
}
