import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/challenges_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/test_container.dart';
import '../../../../../helpers/test_data.dart';

void main() {
  final problems = [
    buildTestProblem(problemId: 1, name: 'Two Sum', problemStatus: ProblemStatus.solved),
    buildTestProblem(problemId: 2, name: 'Three Sum', difficulty: ProblemDifficulty.medium),
    buildTestProblem(
      problemId: 3,
      name: 'Median of Two Sorted Arrays',
      difficulty: ProblemDifficulty.hard,
      problemStatus: ProblemStatus.solved,
    ),
    buildTestProblem(problemId: 4, name: 'Trapping Rain Water', difficulty: ProblemDifficulty.hard),
  ];

  late ProviderContainer container;

  setUp(() {
    container = createTestContainer(
      overrides: [problemsProvider.overrideWithBuild((ref, notifier) => AsyncValue.data(problems))],
    );
    container.listen(challengesProvider, (previous, next) {});
  });

  List<int> shown() => container.read(filteredProblemIdsProvider).value!.ids;
  int solved() => container.read(filteredSolvedCountProvider).value!;
  int tab(ProblemDifficulty difficulty) => container.read(specificDifficultyCountProvider(difficulty)).value!;

  void search(String query) => container.read(challengesProvider.notifier).setSearch(query);
  void filter(ProblemDifficulty difficulty) => container.read(challengesProvider.notifier).setFilter(difficulty);

  test('with no filter or search, everything shows', () {
    expect(shown(), [1, 2, 3, 4]);
    expect(solved(), 2);
  });

  test('each difficulty tab shows only its problems', () {
    filter(ProblemDifficulty.hard);

    expect(shown(), [3, 4]);
    expect(solved(), 1);
  });

  group('search', () {
    test('matches any part of the name, ignoring case', () {
      search('SUM');

      expect(shown(), [1, 2]);
    });

    test('ignores spaces around the query', () {
      search('  two ');

      expect(shown(), [1, 3]);
    });

    test('only spaces is no search', () {
      search('   ');

      expect(shown(), [1, 2, 3, 4]);
    });

    test('no match shows nothing, and nothing solved', () {
      search('graph');

      expect(shown(), isEmpty);
      expect(solved(), 0);
    });

    test('combines with the filter', () {
      filter(ProblemDifficulty.hard);
      search('two');

      expect(shown(), [3]);
      expect(solved(), 1);
    });
  });

  test('each tab counts what the search would show in it', () {
    search('sum');

    expect(tab(ProblemDifficulty.none), 2);
    expect(tab(ProblemDifficulty.easy), 1);
    expect(tab(ProblemDifficulty.medium), 1);
    expect(tab(ProblemDifficulty.hard), 0);
  });

  test('while loading, nothing is counted yet', () {
    final loading = createTestContainer(
      overrides: [problemsProvider.overrideWithBuild((ref, notifier) => const AsyncValue.loading())],
    );

    expect(loading.read(filteredProblemIdsProvider).isLoading, isTrue);
    expect(loading.read(filteredSolvedCountProvider).isLoading, isTrue);
    expect(loading.read(specificDifficultyCountProvider(null)).isLoading, isTrue);
  });

  test('the same ids are equal, so the list does not rebuild for nothing', () {
    expect(const FilteredProblemIds([1, 2]), const FilteredProblemIds([1, 2]));
    expect(const FilteredProblemIds([1, 2]).hashCode, const FilteredProblemIds([1, 2]).hashCode);
    expect(const FilteredProblemIds([1, 2]), isNot(const FilteredProblemIds([2, 1])));
  });
}
