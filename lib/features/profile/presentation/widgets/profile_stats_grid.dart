import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/stat_tile.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/statistics/profile_statistics_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileStatsGrid extends ConsumerWidget {
  const ProfileStatsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(profileStatisticsProvider);

    final solvedSub = '${stats.easySolved}E · ${stats.mediumSolved}M · ${stats.hardSolved}H';
    final streakSub = '${StringsManager.best} ${stats.bestStreak} ${StringsManager.days}';
    final accuracySub = '${(stats.accuracyRate * 100).toStringAsFixed(0)}%';
    final bookmarkSub = '${stats.bookmarkedCount} ${stats.bookmarkedCount>1?StringsManager.problems:StringsManager.problem}';

    final statsList = [
      (
        icon: Icons.check_circle_outline_rounded,
        value: '${stats.solvedCount}',
        label: "${stats.solvedCount>1?StringsManager.problems:StringsManager.problem}\n${StringsManager.solved}",
        sub: solvedSub
      ),
      (
        icon: Icons.local_fire_department_rounded,
        value: '${stats.currentStreak}',
        label: StringsManager.dayStreak,
        sub: streakSub
      ),
      (
        icon: Icons.gps_fixed_rounded,
        value: accuracySub,
        label: StringsManager.accuracyRate,
        sub: ''
      ),
      (
        icon: Icons.bookmark_outline_rounded,
        value: '${stats.bookmarkedCount}',
        label: "${StringsManager.bookmarked}\n",
        sub: bookmarkSub
      ),
    ];

    return HorizontalPadding(
      padding: 16,
      child: Wrap(
        runSpacing: 10.r,
        spacing: 10.r,
        children: statsList.asMap().entries.map(
          (entry) {
            final i = entry.key;
            final s = entry.value;
            final card = SizedBox(
              width: (ScreenUtil().screenWidth / 2) - 21.r,
              child: StatTile(icon: s.icon, value: s.value, label: s.label, sub: s.sub, emphasized: i == 1),
            );
            if (i == 3) {
              return GestureDetector(
                onTap: () => context.pushTo(Routes.bookmarkedProblems),
                child: card,
              );
            }
            return card;
          },
        ).toList(),
      ),
    );
  }
}
