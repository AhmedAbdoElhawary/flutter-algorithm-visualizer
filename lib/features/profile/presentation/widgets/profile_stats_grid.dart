import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/profile/data/profile_stats_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileStatsGrid extends ConsumerWidget {
  const ProfileStatsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(profileStatsProvider);

    final solvedSub = '${stats.easySolved}E · ${stats.mediumSolved}M · ${stats.hardSolved}H';
    final streakSub = '${StringsManager.best}: ${stats.bestStreak} days';
    final accuracySub = '${(stats.accuracyRate * 100).toStringAsFixed(0)}%';
    final bookmarkSub = '${stats.bookmarkedCount} problems';

    final statsList = [
      (
        icon: Icons.check_circle_outline_rounded,
        value: '${stats.solvedCount}',
        label: StringsManager.problemsSolved,
        colorKey: ThemeEnum.accentGreen,
        sub: solvedSub
      ),
      (
        icon: Icons.local_fire_department_rounded,
        value: '${stats.currentStreak}',
        label: StringsManager.dayStreak,
        colorKey: ThemeEnum.accentYellow,
        sub: streakSub
      ),
      (
        icon: Icons.gps_fixed_rounded,
        value: accuracySub,
        label: StringsManager.accuracyRate,
        colorKey: ThemeEnum.accent,
        sub: ''
      ),
      (
        icon: Icons.bookmark_outline_rounded,
        value: '${stats.bookmarkedCount}',
        label: StringsManager.bookmarked,
        colorKey: ThemeEnum.accentBlue,
        sub: bookmarkSub
      ),
    ];

    return HorizontalPadding(
        padding: 16,
        child: Wrap(
          runSpacing: 10.r,
          spacing: 10.r,
          children: statsList
              .map((s) => Container(
                    padding: REdgeInsets.all(14),
                    width: (ScreenUtil().screenWidth / 2) - 21.r,
                    decoration: BoxDecoration(
                      color: context.getColor(ThemeEnum.card),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.getColor(ThemeEnum.border)),
                      boxShadow: context.cardShadow,
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Icon(s.icon, size: 16.r, color: context.getColor(s.colorKey)),
                        const Spacer(),
                        if (s.sub.isNotEmpty) RegularText(s.sub, color: ThemeEnum.hoverSecond, fontSize: 9),
                      ]),
                      RSizedBox(height: 6),
                      BoldText(s.value, color: ThemeEnum.textSecond, fontSize: 20),
                      RSizedBox(height: 2),
                      RegularText(s.label, color: ThemeEnum.hoverSecond, fontSize: 11),
                    ]),
                  ))
              .toList(),
        )
        // GridView.count(
        //   physics: const NeverScrollableScrollPhysics(),
        //   shrinkWrap: true,
        //   crossAxisCount: 2,
        //   crossAxisSpacing: 10.r,
        //   mainAxisSpacing: 10.r,
        //   childAspectRatio: 1.7,
        //   children: ,
        // ),
        );
  }
}
