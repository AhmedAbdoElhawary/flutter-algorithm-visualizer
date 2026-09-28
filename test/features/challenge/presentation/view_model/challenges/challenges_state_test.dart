import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/challenges_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts showing everything, unsearched, with nothing open', () {
    final state = ChallengesState.initial();

    expect(state.filter, ProblemDifficulty.none);
    expect(state.search, '');
    expect(state.expandedId, 0);
  });

  test('copyWith changes only what it is given', () {
    final state = ChallengesState.initial().copyWith(filter: ProblemDifficulty.hard);

    final searched = state.copyWith(search: 'sum');
    expect(searched.filter, ProblemDifficulty.hard);
    expect(searched.search, 'sum');

    final opened = searched.copyWith(expandedId: 4);
    expect(opened.filter, ProblemDifficulty.hard);
    expect(opened.search, 'sum');
    expect(opened.expandedId, 4);

    expect(opened.copyWith().filter, ProblemDifficulty.hard);
  });
}
