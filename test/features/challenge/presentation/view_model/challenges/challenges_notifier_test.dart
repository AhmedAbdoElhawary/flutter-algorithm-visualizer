import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/challenges_notifier.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/challenges_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/test_container.dart';
import '../../../../../helpers/test_data.dart';

void main() {
  final twoSum = buildTestProblem(problemId: 1, name: 'Two Sum');
  final parens = buildTestProblem(problemId: 2, name: 'Valid Parentheses', difficulty: ProblemDifficulty.medium);

  late ProviderContainer container;
  late ChallengesNotifier notifier;

  void build() {
    container = createTestContainer(
      overrides: [problemsProvider.overrideWithBuild((ref, notifier) => AsyncValue.data([twoSum, parens]))],
    );
    container.listen(challengesProvider, (previous, next) {});
    notifier = container.read(challengesProvider.notifier);
  }

  group('filter, search and the open card', () {
    setUp(build);

    test('changing the filter or search closes the open card', () {
      notifier.toggleExpanded(1);
      notifier.setFilter(ProblemDifficulty.easy);
      expect(container.read(challengesProvider).expandedId, 0);

      notifier.toggleExpanded(1);
      notifier.setSearch('two');
      expect(container.read(challengesProvider).expandedId, 0);
      expect(container.read(challengesProvider).search, 'two');

      notifier.toggleExpanded(1);
      notifier.clearSearch();
      expect(container.read(challengesProvider).expandedId, 0);
      expect(container.read(challengesProvider).search, '');
      expect(container.read(challengesProvider).filter, ProblemDifficulty.easy);
    });

    test('one card open at a time; tapping it again closes it', () {
      notifier.toggleExpanded(1);
      notifier.toggleExpanded(2);
      expect(container.read(challengesProvider).expandedId, 2);

      notifier.toggleExpanded(2);
      expect(container.read(challengesProvider).expandedId, 0);
    });

    test('every difficulty is a filter tab', () {
      expect(ChallengesNotifier.filters, ProblemDifficulty.values);
    });
  });

  test('its search box controller is disposed with it', () {
    build();
    final controller = notifier.textController;

    container.dispose();

    expect(() => controller.addListener(() {}), throwsFlutterError);
  });
}
