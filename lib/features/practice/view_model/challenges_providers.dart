import 'package:algorithm_visualizer/features/practice/helper/problem.dart';
import 'package:algorithm_visualizer/features/practice/temp_data/problems_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'challenges_notifier.dart';

final problemsProvider = Provider<List<Problem>>((ref) => problems);

final filteredProblemsProvider = Provider<List<Problem>>((ref) {
  final all = ref.watch(problemsProvider);
  final state = ref.watch(challengesProvider);

  return all.where((p) {
    if (state.filter != ProblemDifficulty.all && p.difficulty != state.filter) return false;
    if (state.search.isNotEmpty && !p.name.toLowerCase().contains(state.search.toLowerCase())) {
      return false;
    }
    return true;
  }).toList();
});

final solvedCountProvider = Provider<int>((ref) {
  return ref.watch(problemsProvider).where((p) => p.isSolved).length;
});

final difficultyCountProvider = Provider.family<int, ProblemDifficulty>((ref, filter) {
  final all = ref.watch(problemsProvider);
  return filter == ProblemDifficulty.all ? all.length : all.where((p) => p.difficulty == filter).length;
});
