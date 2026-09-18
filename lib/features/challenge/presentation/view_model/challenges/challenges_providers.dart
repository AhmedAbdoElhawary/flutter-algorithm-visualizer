import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:collection/collection.dart' show ListEquality;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'challenges_notifier.dart';
import 'challenges_state.dart';

final challengesProvider = NotifierProvider.autoDispose<ChallengesNotifier, ChallengesState>(() {
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

bool _matchesSearch(CodingProblem problem, String search) {
  return search.isEmpty || problem.getName.toLowerCase().contains(search.toLowerCase());
}

bool _matchesFilter(CodingProblem problem, ProblemDifficulty? filter, String search) {
  if (filter != null && filter != ProblemDifficulty.none && problem.difficulty != filter) {
    return false;
  }
  return _matchesSearch(problem, search);
}

/// Auto-disposing: this is derived, per-screen state. Once the challenges
/// list is gone — a different tab is fine, but a sign-out tears the whole
/// shell down — the cached filter result should go with it rather than
/// outlive the account that produced it.
final filteredProblemIdsProvider = Provider.autoDispose<AsyncValue<FilteredProblemIds>>((ref) {
  /// Only the two fields the filter actually reads, the same way
  /// [specificDifficultyCountProvider] below already does it.
  ///
  /// Watching the whole [challengesProvider] here meant that opening a tile —
  /// which only moves `expandedId` — re-ran this filter over all 100 problems
  /// and then a `ListEquality` comparison over the result, to arrive at the
  /// list it already had. Records compare by value, so a change to any other
  /// field of the state no longer reaches this provider at all.
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

/// Count of problems matching [filter] under the currently active search —
/// this is what keeps the difficulty tab counts live while the user types.
/// Auto-disposing for the same reason as [filteredProblemIdsProvider], and one
/// more: a family keeps a separate provider per argument, so without this every
/// difficulty tab ever opened stays in the container for the rest of the run.
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
