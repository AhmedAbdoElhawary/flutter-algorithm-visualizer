import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/glass_card.dart';
import 'package:algorithm_visualizer/features/home/view_model/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileWeeklyChart extends ConsumerWidget {
  const ProfileWeeklyChart({super.key});

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekly = ref.watch(homeDataProvider.select((s) => s.stats.weeklyActivity));
    final maxVal = weekly.isEmpty ? 1 : (weekly.reduce((a, b) => a > b ? a : b)).clamp(1, 999);
    final total = weekly.fold<int>(0, (a, b) => a + b);

    return OnlyPadding(
      startPadding: 16,
      endPadding: 16,
      bottomPadding: 14,
      child: SimpleGlassButton(
        padding: 14,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              BoldText(StringsManager.thisWeek, color: ThemeEnum.textSecond, fontSize: 14),
              SemiBoldText(
                '$total ${StringsManager.solvedLabel}',
                color: ThemeEnum.accent,
                fontSize: 12,
              ),
            ]),
            SizedBox(height: 12.h),
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
                          RSizedBox(height: 4),
                          Container(
                            height: (50.h * fraction).clamp(4.0, 50.0),
                            decoration: BoxDecoration(
                              color: isToday
                                  ? context.getColor(ThemeEnum.accent)
                                  : context.getColor(ThemeEnum.accent).withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          RSizedBox(height: 6),
                          RegularText(
                            _dayLabels[i],
                            fontSize: 10,
                            color: isToday ? ThemeEnum.accent : ThemeEnum.textSecond,
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
