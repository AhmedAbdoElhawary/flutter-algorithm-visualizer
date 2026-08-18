import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challange/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challange/presentation/view_model/challenges/problems_notifier.dart';
import 'package:algorithm_visualizer/features/profile/presentation/entities/profile_statistics.dart';
import 'package:algorithm_visualizer/features/profile/presentation/entities/recent_submission.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/statistics/profile_statistics_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// no needed to over engineer and separate theme, just to be different than others view model, but it's clear and not complicated here
/// so, i didn't seperated it to provider and notifier
class HomeData {
  const HomeData({
    required this.greeting,
    required this.stats,
    required this.continueProblem,
    required this.recentActivity,
  });

  final String greeting;
  final ProfileStatistics stats;
  final CodingProblem? continueProblem;
  final List<RecentSubmission> recentActivity;
}

final homeDataProvider = Provider<HomeData>((ref) {
  final asyncProblems = ref.watch(problemsProvider);
  final stats = ref.watch(profileStatisticsProvider);

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
