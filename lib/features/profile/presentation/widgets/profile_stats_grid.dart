import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/profile/data/profile_stats_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ProfileStatsGrid extends ConsumerWidget {
  const ProfileStatsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(profileStatsProvider);

    final solvedSub = '${stats.easySolved}E · ${stats.mediumSolved}M · ${stats.hardSolved}H';
    final streakSub = '${StringsManager.best} ${stats.bestStreak} ${StringsManager.days}';
    final accuracySub = '${(stats.accuracyRate * 100).toStringAsFixed(0)}%';
    final bookmarkSub = '${stats.bookmarkedCount} ${StringsManager.problems}';

    final statsList = [
      (
        icon: Icons.check_circle_outline_rounded,
        value: '${stats.solvedCount}',
        label: "${StringsManager.problems}\n${StringsManager.solved}",
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
        label: "${StringsManager.bookmarked}\n",
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
            .asMap()
            .entries
            .map(
              (entry) {
                final i = entry.key;
                final s = entry.value;
                final card = Container(
                padding: REdgeInsets.all(14),
                width: (ScreenUtil().screenWidth / 2) - 21.r,
                decoration: BoxDecoration(
                  color: context.getColor(ThemeEnum.card),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.getColor(ThemeEnum.border)),
                  boxShadow: context.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      CustomIcon(s.icon, size: 18, color: s.colorKey),
                      const Spacer(),
                      if (s.sub.isNotEmpty) MediumText(s.sub, color: ThemeEnum.hover, fontSize: 10),
                    ]),
                    RSizedBox(height: 6),
                    BoldText(s.value, color: ThemeEnum.textPrimary, fontSize: 20,fontWeight: FontWeightManager.bold900,),
                    RSizedBox(height: 2),
                    MediumText(s.label, color: ThemeEnum.hover, fontSize: 11),
                  ],
                ),
              );
                if (i == 3) {
                  return GestureDetector(
                    onTap: () => context.push('/profile/bookmarked'),
                    child: card,
                  );
                }
                return card;
              },
            )
            .toList(),
      ),
    );
  }
}
