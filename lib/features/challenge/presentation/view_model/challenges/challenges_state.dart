import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';

class ChallengesState {
  final ProblemDifficulty? filter;
  final String search;
  final int expandedId;

  const ChallengesState({
    required this.filter,
    required this.search,
    required this.expandedId,
  });

  factory ChallengesState.initial() =>
      const ChallengesState(filter: ProblemDifficulty.none, search: "", expandedId: 0);

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
