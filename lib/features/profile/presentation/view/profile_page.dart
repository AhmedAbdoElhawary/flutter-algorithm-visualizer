import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_category_chart.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_difficulty_progress.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_header.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_heatmap.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_logout_card.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_practice_history.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_stats_grid.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_weekly_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.getColor(ThemeEnum.primary),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: REdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 14.r,
            children: [
              ProfileHeader(),
              const ProfileStatsGrid(),
              const ProfileDifficultyProgress(),
              const ProfileWeeklyChart(),
              const ProfileHeatmap(),
              const ProfileCategoryChart(),
              const ProfilePracticeHistory(),
              const ProfileLogoutCard(),
            ],
          ),
        ),
      ),
    );
  }
}

