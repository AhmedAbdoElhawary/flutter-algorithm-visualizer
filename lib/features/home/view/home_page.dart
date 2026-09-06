import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/features/home/view/movable_pins.dart';
import 'package:algorithm_visualizer/features/home/view/widgets/home_category_grid.dart';
import 'package:algorithm_visualizer/features/home/view/widgets/home_continue_card.dart';
import 'package:algorithm_visualizer/features/home/view/widgets/home_difficulty_progress.dart';
import 'package:algorithm_visualizer/features/home/view/widgets/home_header.dart';
import 'package:algorithm_visualizer/features/home/view/widgets/home_recent_activity.dart';
import 'package:algorithm_visualizer/features/home/view/widgets/home_stats_strip.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_weekly_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.getColor(ThemeEnum.primary),
      body: SafeArea(
        child: MovablePinsBackground(
          pinColor: ThemeEnum.whiteD4Color,
          // Isolate the scrolling content into its own compositor layer so a
          // scroll doesn't re-rasterize the static orb background behind it.
          child: RepaintBoundary(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // SliverList.list wraps each section in its own RepaintBoundary
                // and only builds sections near the viewport, so painting one
                // section can't invalidate the others.
                SliverList.list(
                  children: const [
                    HomeHeader(),
                    HomeStatsStrip(),
                    ProfileWeeklyChart(),
                    HomeDifficultyProgress(),
                    HomeContinueCard(),
                    HomeCategoryGrid(),
                    HomeRecentActivity(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
