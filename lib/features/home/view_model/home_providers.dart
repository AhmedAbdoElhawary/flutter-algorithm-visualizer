import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challange/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challange/presentation/view_model/challenges/problems_notifier.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/profile_stats_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeData {
  const HomeData({
    required this.greeting,
    required this.stats,
    required this.continueProblem,
    required this.recentActivity,
  });

  final String greeting;
  final ProfileStats stats;
  final CodingProblem? continueProblem;
  final List<RecentSubmission> recentActivity;
}

class CategoryItem {
  const CategoryItem({
    required this.name,
    required this.solved,
    required this.total,
    required this.icon,
  });

  final String name;
  final int solved;
  final int total;
  final IconData icon;
}

final homeDataProvider = Provider<HomeData>((ref) {
  final asyncProblems = ref.watch(problemsProvider);
  final stats = ref.watch(profileStatsProvider);

  return asyncProblems.when(
    data: (problems) {
      final greeting = _computeGreeting();
      final continueProblem = _findContinueProblem(problems);
      final recentActivity = stats.recentSubmissions;

      return HomeData(
        greeting: greeting,
        stats: stats,
        continueProblem: continueProblem,
        recentActivity: recentActivity,
      );
    },
    loading: () => HomeData(
      greeting: _computeGreeting(),
      stats: stats,
      continueProblem: null,
      recentActivity: [],
    ),
    error: (_, __) => HomeData(
      greeting: _computeGreeting(),
      stats: stats,
      continueProblem: null,
      recentActivity: [],
    ),
  );
});

String _computeGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return StringsManager.goodMorning;
  if (hour < 17) return StringsManager.goodAfternoon;
  return StringsManager.goodEvening;
}

CodingProblem? _findContinueProblem(List<CodingProblem> problems) {
  final attempted = problems.where((p) => !p.isSolved && p.getSolutionsStatus.isNotEmpty).toList();
  if (attempted.isNotEmpty) return attempted.first;

  final unsolved = problems.where((p) => !p.isSolved).toList();
  return unsolved.isNotEmpty ? unsolved.first : null;
}
