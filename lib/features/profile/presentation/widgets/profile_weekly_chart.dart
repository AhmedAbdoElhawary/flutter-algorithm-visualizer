import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/styles_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/profile/data/profile_stats_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileWeeklyChart extends ConsumerWidget {
  const ProfileWeeklyChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(profileStatsProvider);
    final weekly = stats.weeklyActivity;
    final total = weekly.fold<int>(0, (a, b) => a + b);
    final isDark = context.isThemeDark;

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
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              BoldText(StringsManager.thisWeek, color: ThemeEnum.textSecond, fontSize: 13),
              SemiBoldText('$total ${StringsManager.solvedLabel}', color: ThemeEnum.accent, fontSize: 12),
            ]),
            RSizedBox(height: 12),
            SizedBox(
              height: 70.r,
              child: BarChart(
                BarChartData(
                  barGroups: weekly.asMap().entries.map((e) {
                    final i = e.key;
                    final value = e.value;
                    return BarChartGroupData(x: i, barRods: [
                      BarChartRodData(
                        toY: value.toDouble(),
                        color: i == DateTime.now().weekday - 1
                            ? context.getColor(ThemeEnum.accent)
                            : context.getColor(ThemeEnum.accent).withValues(alpha: isDark ? 0.22 : 0.15),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
                        width: 18.w,
                      ),
                    ]);
                  }).toList(),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(getTooltipColor: (group) => context.getColor(ThemeEnum.outputHeader),
                      getTooltipItem: (group, gIdx, rod, rIdx) => BarTooltipItem(
                        '${rod.toY.toInt()} ${StringsManager.solvedLabel}',
                        GetSemiBoldStyle(color:context.isThemeDark? ColorManager.textPrimaryDk: ColorManager.textPrimaryLt, fontSize: 11),
                      ),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        final i = v.toInt();
                        if (i < 0 || i >= days.length) return const SizedBox();
                        return Padding(
                          padding: REdgeInsets.only(top: 4),
                          child: MediumText(days[i], color: ThemeEnum.hoverSecond, fontSize: 11),
                        );
                      },
                    )),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
