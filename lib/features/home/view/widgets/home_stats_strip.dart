import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/stat_tile.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/statistics/profile_statistics_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      ),
      (
        icon: Icons.check_circle_outline_rounded,
        value: '${stats.solvedCount}',
        label: StringsManager.solved,
      ),
      (
        icon: Icons.gps_fixed_rounded,
        value: '${(stats.accuracyRate * 100).round()}%',
        label: StringsManager.accuracy,
      ),
      (
        icon: Icons.trending_up_rounded,
        value: '${stats.totalAttempts}',
        label: StringsManager.attempts,
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
            child: StatTile(icon: s.icon, value: s.value, label: s.label),
          );
        }).toList(),
      ),
    );
  }
}
