import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/glass_card.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/statistics/profile_statistics_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeStatsStrip extends ConsumerWidget {
  const HomeStatsStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(profileStatisticsProvider);

    final items = [
      (
        icon: Icons.local_fire_department_rounded,
        value: '${stats.currentStreak}',
        label: StringsManager.streak,
        color: ThemeEnum.accentYellow
      ),
      (
        icon: Icons.check_circle_outline_rounded,
        value: '${stats.solvedCount}',
        label: StringsManager.solved,
        color: ThemeEnum.accentGreen
      ),
      (
        icon: Icons.gps_fixed_rounded,
        value: '${(stats.accuracyRate * 100).round()}%',
        label: StringsManager.accuracy,
        color: ThemeEnum.accent
      ),
      (
        icon: Icons.trending_up_rounded,
        value: '${stats.totalAttempts}',
        label: StringsManager.attempts,
        color: ThemeEnum.accentBlue
      ),
    ];

    return OnlyPadding(
      startPadding: 16,
      endPadding: 16,
      bottomPadding: 14,
      child: Row(
        children: items.map((s) {
          final isLast = s == items.last;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: isLast ? 0 : 8.w),
              padding: REdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: SimpleGlassButton.cardDecoration(context),
              child: Column(
                children: [
                  Icon(s.icon, size: 18.r, color: context.getColor(s.color)),
                  SizedBox(height: 4.h),
                  BoldText(
                    s.value,
                    fontSize: 17,
                    color: ThemeEnum.textPrimary,
                    letterSpacing: -0.5,
                  ),
                  SizedBox(height: 2.h),
                  MediumText(
                    s.label,
                    fontSize: 10,
                    color: ThemeEnum.textSecond,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
