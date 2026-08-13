import 'package:algorithm_visualizer/features/challange/domain/enums/problem.dart';
import 'package:flutter/foundation.dart';

@immutable
class ChallengesState {
  final ProblemDifficulty? filter;
  final String search;
  final int expandedId;

  const ChallengesState({
    this.filter,
    this.search = '',
    this.expandedId = 0,
  });

  ChallengesState copyWith({
    ProblemDifficulty? filter,
    String? search,
    int? expandedId,
  }) {
    return ChallengesState(
      filter: search == null && expandedId == null ? filter : this.filter,
      search: search ?? this.search,
      expandedId: expandedId ?? this.expandedId,
    );
  }
}
