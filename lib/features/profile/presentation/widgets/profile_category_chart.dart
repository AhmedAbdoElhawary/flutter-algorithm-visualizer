import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/profile/data/profile_stats_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileCategoryChart extends ConsumerWidget {
  const ProfileCategoryChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(profileStatsProvider);

    if (stats.categorySolved.isEmpty) return const SizedBox.shrink();

    final sorted = stats.categorySolved.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(6).toList();
    final maxVal = top.first.value;

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
          BoldText(StringsManager.categoryBreakdown, color: ThemeEnum.textSecond, fontSize: 13),
          RSizedBox(height: 12),
          SizedBox(
            height: 160.h,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal.toDouble(),
                barGroups: top.asMap().entries.map((e) {
                  final i = e.key;
                  final entry = e.value;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.toDouble(),
                        color: context.getColor(ThemeEnum.accent).withValues(alpha: 0.7),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
                        width: 18.w,
                      ),
                    ],
                  );
                }).toList(),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, gIdx, rod, rIdx) {
                      final name = top[group.x].key;
                      return BarTooltipItem(
                        '$name (${rod.toY.toInt()})',
                        TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w600),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= top.length) return const SizedBox();
                        final label = top[i].key;
                        final short = label.length > 8 ? label.substring(0, 8) : label;
                        return Padding(
                          padding: REdgeInsets.only(top: 4),
                          child: MediumText(short, color: ThemeEnum.hoverSecond, fontSize: 9),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
