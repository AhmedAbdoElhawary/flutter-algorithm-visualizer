import 'package:algorithm_visualizer/core/helpers/constants.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/glass_card.dart';
import 'package:algorithm_visualizer/features/home/view/widgets/home_category_grid.dart';
import 'package:algorithm_visualizer/features/home/view/widgets/home_continue_card.dart';
import 'package:algorithm_visualizer/features/home/view/widgets/home_difficulty_progress.dart';
import 'package:algorithm_visualizer/features/home/view/widgets/home_header.dart';
import 'package:algorithm_visualizer/features/home/view/widgets/home_recent_activity.dart';
import 'package:algorithm_visualizer/features/home/view/widgets/home_stats_strip.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_weekly_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.getColor(ThemeEnum.primary),
      body: AuroraGround(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverList.list(
              children: const [
                HomeHeader(),
                HomeStatsStrip(),
                ProfileWeeklyChart(),
                HomeDifficultyProgress(),
                HomeContinueCard(),
                HomeCategoryGrid(),
                HomeRecentActivity(),
                RSizedBox(height: kBottomPageSpacing)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
