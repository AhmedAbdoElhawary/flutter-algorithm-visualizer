import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/profile/domain/entities/profile_statistics.dart';
import 'package:riverpod/riverpod.dart';

import '../../../domain/entities/practice_history_entry.dart';
import '../../../domain/entities/recent_submission.dart';

part 'profile_statistics_calculator.dart';

final profileStatisticsCalculatorProvider =
    Provider<ProfileStatisticsCalculator>((ref) => const ProfileStatisticsCalculator());

final profileStatisticsProvider = Provider<ProfileStatistics>((ref) {
  final asyncProblems = ref.watch(problemsProvider);
  final calculator = ref.watch(profileStatisticsCalculatorProvider);

  return asyncProblems.when(
    data: calculator.computeStats,
    loading: ProfileStatistics.empty,
    error: (_, __) => ProfileStatistics.empty(),
  );
});
