import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'challenges_state.dart';

class ChallengesNotifier extends Notifier<ChallengesState> {
  static const filters = ProblemDifficulty.values;
  final textController = TextEditingController();

  @override
  ChallengesState build() {
    ref.onDispose(() {
      textController.dispose();
    });
    return ChallengesState.initial();
  }

  void setFilter(ProblemDifficulty filter) => state = state.copyWith(filter: filter, expandedId: 0);

  void setSearch(String query) => state = state.copyWith(search: query, expandedId: 0);

  void clearSearch() => state = state.copyWith(search: '', expandedId: 0);

  void toggleExpanded(int problemId) {
    if (state.expandedId == problemId) {
      state = state.copyWith(expandedId: 0);
    } else {
      state = state.copyWith(expandedId: problemId);
    }
  }
}
