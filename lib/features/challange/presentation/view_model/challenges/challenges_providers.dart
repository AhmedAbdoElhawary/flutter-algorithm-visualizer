import 'package:algorithm_visualizer/features/challange/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challange/domain/enums/problem.dart';
import 'package:collection/collection.dart' show IterableExtension, ListEquality;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'challenges_notifier.dart';
import 'challenges_state.dart';
import 'problems_notifier.dart';

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

/// The full problem for a single id. `.select` gives per-problem granularity:
/// when another problem changes, this recomputes to the *same* (freezed-equal)
/// problem and Riverpod skips the notification, so only the tile watching this
/// id rebuilds.
final getProblemProvider = Provider.family<AsyncValue<CodingProblem?>, int>((ref, problemId) {
  if (problemId <= 0) return const AsyncValue.data(null);
  return ref.watch(
    problemsProvider.select(
      (async) => async.whenData(
        (problems) => problems.firstWhereOrNull((problem) => problem.problemId == problemId),
      ),
    ),
  );
});

/// The number of solved problems. Notifies only when the count actually
/// changes (e.g. a failed attempt on an unsolved problem doesn't rebuild the
/// header's solved counter).
final solvedCountProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(
    problemsProvider.select(
      (async) => async.whenData((problems) => problems.where((problem) => problem.isSolved).length),
    ),
  );
});

final difficultyCountProvider = Provider.family<AsyncValue<int>, ProblemDifficulty?>(
  (ref, filter) {
    return ref.watch(
      problemsProvider.select(
        (async) => async.whenData((problems) {
          if (filter == null || filter == ProblemDifficulty.none) return problems.length;
          return problems.where((problem) => problem.difficulty == filter).length;
        }),
      ),
    );
  },
);
