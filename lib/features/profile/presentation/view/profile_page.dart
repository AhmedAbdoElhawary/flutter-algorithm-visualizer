import 'package:algorithm_visualizer/core/helpers/constants.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_category_chart.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_difficulty_progress.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_header.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_heatmap.dart';
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
    // Scaffold/Metrial written in base_navigation, why?
    // to control all main pages with the structure of them
    return const Material(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeader(),
            RSizedBox(height: 14),
            ProfileStatsGrid(),
            RSizedBox(height: 14),
            ProfileDifficultyProgress(),
            RSizedBox(height: 14),
            ProfileWeeklyChart(),
            ProfileHeatmap(),
            ProfileSolvedTopics(),
            ProfilePracticeHistory(),
            RSizedBox(height: kBottomPageSpacing),
          ],
        ),
      ),
    );
  }
}
