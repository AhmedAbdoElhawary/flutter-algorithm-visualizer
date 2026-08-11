import 'package:algorithm_visualizer/features/practice/helper/problem.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'challenges_state.dart';

class ChallengesNotifier extends Notifier<ChallengesState> {
  static const filters = ProblemDifficulty.values;

  @override
  ChallengesState build() => const ChallengesState();

  void setFilter(ProblemDifficulty filter) => state = state.copyWith(filter: filter);

  void setSearch(String query) => state = state.copyWith(search: query);

  void clearSearch() => state = state.copyWith(search: '');

  void toggleExpanded(int problemId) {
    if (state.expandedId == problemId) {
      state = state.copyWith(expandedId: 0);
    }else{

      state = state.copyWith(expandedId: problemId);
    }
  }
}

final challengesProvider = NotifierProvider<ChallengesNotifier, ChallengesState>(ChallengesNotifier.new);
