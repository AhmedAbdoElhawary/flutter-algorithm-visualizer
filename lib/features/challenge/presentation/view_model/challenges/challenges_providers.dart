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

/// The ids of the problems matching the current filter/search, in dataset
/// order, wrapped so equality is by content rather than list identity.
///
/// This is what lets `filteredProblemIdsProvider` `.select` a *stable* value:
/// a solution update doesn't change which ids are filtered, so the list page
/// itself doesn't rebuild — only the affected tile (via `getProblemProvider`)
/// does.
class FilteredProblemIds {
  const FilteredProblemIds(this.ids);

  final List<int> ids;

  @override
  bool operator ==(Object other) =>
      other is FilteredProblemIds && const ListEquality<int>().equals(other.ids, ids);

  @override
  int get hashCode => const ListEquality<int>().hash(ids);
}

bool _matchesFilter(CodingProblem problem, ChallengesState state) {
  if (state.filter != null && state.filter != ProblemDifficulty.none && problem.difficulty != state.filter) {
    return false;
  }
  if (state.search.isNotEmpty && !problem.getName.toLowerCase().contains(state.search.toLowerCase())) {
    return false;
  }
  return true;
}

final filteredProblemIdsProvider = Provider<AsyncValue<FilteredProblemIds>>((ref) {
  final state = ref.watch(challengesProvider);
  return ref.watch(
    problemsProvider.select(
      (async) => async.whenData(
        (problems) => FilteredProblemIds(
          problems
              .where((problem) => _matchesFilter(problem, state))
              .map((problem) => problem.problemId)
              .whereType<int>()
              .toList(),
        ),
      ),
    ),
  );
});
