import 'package:algorithm_visualizer/features/challange/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challange/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challange/presentation/view_model/challenges/problems_notifier.dart';
import 'package:algorithm_visualizer/features/profile/presentation/entities/profile_statistics.dart';
import 'package:riverpod/riverpod.dart';

import '../../entities/practice_history_entry.dart';
import '../../entities/recent_submission.dart';

part 'profile_statistics_calculator.dart';

final profileStatisticsCalculatorProvider =
    Provider<_ProfileStatisticsCalculator>((ref) => const _ProfileStatisticsCalculator());

final profileStatisticsProvider = Provider<ProfileStatistics>((ref) {
  final asyncProblems = ref.watch(problemsProvider);
  final calculator = ref.watch(profileStatisticsCalculatorProvider);

  return asyncProblems.when(
    data: calculator.computeStats,
    loading: ProfileStatistics.empty,
    error: (_, __) => ProfileStatistics.empty(),
  );
});
