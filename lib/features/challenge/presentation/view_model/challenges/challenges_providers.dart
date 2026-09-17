import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:collection/collection.dart' show ListEquality;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'challenges_notifier.dart';
import 'challenges_state.dart';

final challengesProvider = NotifierProvider<ChallengesNotifier, ChallengesState>(() {
  return ChallengesNotifier();
});

class FilteredProblemIds {
  const FilteredProblemIds(this.ids);

  final List<int> ids;

  @override
  bool operator ==(Object other) =>
      other is FilteredProblemIds && const ListEquality<int>().equals(other.ids, ids);

  @override
  int get hashCode => const ListEquality<int>().hash(ids);
}

bool _matchesSearch(CodingProblem problem, String search) {
  return search.isEmpty || problem.getName.toLowerCase().contains(search.toLowerCase());
}

bool _matchesFilter(CodingProblem problem, ProblemDifficulty? filter, String search) {
  if (filter != null && filter != ProblemDifficulty.none && problem.difficulty != filter) {
    return false;
  }
  return _matchesSearch(problem, search);
}

final filteredProblemIdsProvider = Provider.autoDispose<AsyncValue<FilteredProblemIds>>((ref) {
  final (filter, search) = ref.watch(challengesProvider.select((s) => (s.filter, s.search)));
  return ref.watch(
    problemsProvider.select(
      (async) => async.whenData(
        (problems) => FilteredProblemIds(
          problems
              .where((problem) => _matchesFilter(problem, filter, search))
              .map((problem) => problem.problemId)
              .whereType<int>()
              .toList(),
        ),
      ),
    ),
  );
});

final specificDifficultyCountProvider = Provider.autoDispose.family<AsyncValue<int>, ProblemDifficulty?>(
  (ref, filter) {
    final search = ref.watch(challengesProvider.select((s) => s.search));
    return ref.watch(
      problemsProvider.select(
        (async) => async.whenData((problems) {
          return problems.where((problem) {
            if (filter != null && filter != ProblemDifficulty.none && problem.difficulty != filter) {
              return false;
            }
            return _matchesSearch(problem, search);
          }).length;
        }),
      ),
    );
  },
);
