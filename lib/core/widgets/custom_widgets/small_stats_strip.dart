import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/stat_tile.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/statistics/profile_statistics_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SmallStatsStrip extends ConsumerWidget {
  const SmallStatsStrip({
    this.showAttempts = true,
    this.showIcons = true,
    this.centerTheContent = false,
    super.key,
  });
  final bool showAttempts;
  final bool showIcons;
  final bool centerTheContent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(profileStatisticsProvider);

    final items = [
      (
        icon: Icons.local_fire_department_rounded,
        value: '${stats.currentStreak}',
        label: StringsManager.streak,
        iconColor: ThemeEnum.dataHard,
      ),
      (
        icon: Icons.check_circle_outline_rounded,
        value: '${stats.solvedCount}',
        label: StringsManager.solved,
        iconColor: ThemeEnum.dataEasy,
      ),
      (
        icon: Icons.gps_fixed_rounded,
        value: '${(stats.accuracyRate * 100).round()}%',
        label: StringsManager.accuracy,
        iconColor: ThemeEnum.inkPrimary,
      ),
      if (showAttempts)
        (
          icon: Icons.trending_up_rounded,
          value: '${stats.totalAttempts}',
          label: StringsManager.attempts,
          iconColor: null,
        ),
    ];

    return OnlyPadding(
      startPadding: 16,
      endPadding: 16,
      bottomPadding: 14,
      child: Row(
        spacing: 10,
        children: items.map((s) {
          return Expanded(
            child: StatTile(
                icon: showIcons ? s.icon : null,
                value: s.value,
                label: s.label,
                iconColor: s.iconColor,
                centerTheContent: centerTheContent),
          );
        }).toList(),
      ),
    );
  }
}
