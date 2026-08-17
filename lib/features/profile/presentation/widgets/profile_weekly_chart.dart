import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/profile/data/profile_stats_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileWeeklyChart extends ConsumerStatefulWidget {
  const ProfileWeeklyChart({super.key});

  @override
  ConsumerState<ProfileWeeklyChart> createState() => _ProfileWeeklyChartState();
}

class _ProfileWeeklyChartState extends ConsumerState<ProfileWeeklyChart> {
  int? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(profileStatsProvider);
    final weekly = stats.weeklyActivity;
    final total = weekly.fold<int>(0, (a, b) => a + b);
    final isDark = context.isThemeDark;

    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

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
              SemiBoldText(
                _selectedDay != null
                    ? '${days[_selectedDay!]}: ${weekly[_selectedDay!]} ${StringsManager.solvedLabel}'
                    : '$total ${StringsManager.solvedLabel}',
                color: ThemeEnum.accent,
                fontSize: 12,
              ),
            ]),
            RSizedBox(height: 12),
            SizedBox(
              height: 70.r,
              child: BarChart(
                BarChartData(
                  barGroups: weekly.asMap().entries.map((e) {
                    final i = e.key;
                    final value = e.value;
                    final isSelected = _selectedDay == i;
                    final isToday = i == DateTime.now().weekday - 1;
                    return BarChartGroupData(x: i, barRods: [
                      BarChartRodData(
                        toY: value.toDouble(),
                        color: isSelected
                            ? context.getColor(ThemeEnum.accent)
                            : isToday
                                ? context.getColor(ThemeEnum.accent)
                                    .withValues(alpha: isDark ? 0.5 : 0.4)
                                : context.getColor(ThemeEnum.accent)
                                    .withValues(alpha: isDark ? 0.22 : 0.15),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
                        width: 18.w,
                      ),
                    ]);
                  }).toList(),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => context.getColor(ThemeEnum.outputHeader),
                      getTooltipItem: (group, gIdx, rod, rIdx) {
                        final dayName = days[group.x];
                        return BarTooltipItem(
                          '$dayName: ${rod.toY.toInt()}',
                          TextStyle(
                            color: context.getColor(ThemeEnum.textPrimary),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                    touchCallback: (event, response) {
                      if (response?.spot != null && event is FlTapUpEvent) {
                        final idx = response!.spot!.touchedBarGroupIndex;
                        setState(() {
                          _selectedDay = _selectedDay == idx ? null : idx;
                        });
                      }
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        const dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        final i = v.toInt();
                        if (i < 0 || i >= dayLetters.length) return const SizedBox();
                        final isToday = i == DateTime.now().weekday - 1;
                        return Padding(
                          padding: REdgeInsets.only(top: 4),
                          child: MediumText(
                            dayLetters[i],
                            color: isToday ? ThemeEnum.accent : ThemeEnum.hoverSecond,
                            fontSize: 11,
                          ),
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
