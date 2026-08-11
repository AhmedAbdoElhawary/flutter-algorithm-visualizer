import 'package:algorithm_visualizer/features/practice/helper/problem.dart';
import 'package:flutter/foundation.dart';

@immutable
class ChallengesState {
  final ProblemDifficulty filter;
  final String search;
  final int expandedId;

  const ChallengesState({
    this.filter = ProblemDifficulty.all,
    this.search = '',
    this.expandedId = 0,
  });

  ChallengesState copyWith({
    ProblemDifficulty? filter,
    String? search,
    int? expandedId,
  }) {
    return ChallengesState(
      filter: filter ?? this.filter,
      search: search ?? this.search,
      expandedId: expandedId ?? this.expandedId,
    );
  }
}
