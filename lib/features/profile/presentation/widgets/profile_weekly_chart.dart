import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/bar_chart_quiet.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/section_header.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/statistics/profile_statistics_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileWeeklyChart extends ConsumerWidget {
  const ProfileWeeklyChart({super.key});

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekly = ref.watch(profileStatisticsProvider.select((s) => s.weeklyActivity));
    final maxVal = weekly.isEmpty ? 1 : (weekly.reduce((a, b) => a > b ? a : b)).clamp(1, 999);
    final total = weekly.fold<int>(0, (a, b) => a + b);

    return OnlyPadding(
      startPadding: 16,
      endPadding: 16,
      bottomPadding: 14,
      child: CardContainer(
        surface: CdSurface.main,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: StringsManager.thisWeek, trailing: '$total ${StringsManager.solvedLabel}'),
            const RSizedBox(height: 12),
            RSizedBox(
              height: 90,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final val = i < weekly.length ? weekly[i] : 0;
                  final fraction = val / maxVal;
                  final isToday = i == (DateTime.now().weekday - 1);

                  return Expanded(
                    child: Padding(
                      padding: REdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (val > 0)
                            MediumText(
                              '$val',
                              fontSize: 9,
                              color: ThemeEnum.textSecond,
                            ),
                          const RSizedBox(height: 4),
                          QuietBar(
                            width: double.infinity,
                            height: (50.r * fraction).clamp(4.0, 50.0),
                            fill: isToday ? ThemeEnum.difficultyEasy : ThemeEnum.barIdle,
                          ),
                          const RSizedBox(height: 6),
                          RegularText(
                            _dayLabels[i],
                            fontSize: 10,
                            color: isToday ? ThemeEnum.textPrimary : ThemeEnum.textSecond,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
