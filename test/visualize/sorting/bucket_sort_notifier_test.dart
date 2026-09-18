import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sub_sorting/bucket_sort_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late BucketSortNotifier notifier;

  setUp(() => notifier = BucketSortNotifier());

  group('BucketSortNotifier', () {
    for (final (:name, :input, :expected) in [
      (name: 'empty input', input: <int>[], expected: <int>[]),
      (name: 'one item', input: [7], expected: [7]),
      (
        name: 'already sorted values',
        input: [1, 2, 3, 4],
        expected: [1, 2, 3, 4],
      ),
      (
        name: 'reverse-sorted values',
        input: [9, 7, 5, 3, 1],
        expected: [1, 3, 5, 7, 9],
      ),
      (
        name: 'random unsorted values',
        input: [8, 1, 6, 3, 5, 2],
        expected: [1, 2, 3, 5, 6, 8],
      ),
      (
        name: 'duplicate values',
        input: [4, 2, 4, 1, 2, 3],
        expected: [1, 2, 2, 3, 4, 4],
      ),
      (
        name: 'negative values',
        input: [-3, -1, -7, -2],
        expected: [-7, -3, -2, -1],
      ),
      (
        name: 'mixed negative and positive values',
        input: [-1, 8, -4, 0, 1, 6, 2, 3],
        expected: [-4, -1, 0, 1, 2, 3, 6, 8],
      ),
      (name: 'all equal values', input: [5, 5, 5, 5], expected: [5, 5, 5, 5]),
    ]) {
      test('sorts $name and emits valid replay steps', () {
        final result = notifier.buildSorting(input);

        expect(result.sortedValues, expected);
        expect(result.steps, isA<List<SortStep>>());
        _expectValidSteps(result.steps, input.length, notifier.roles);
        expect(_replay(input, result.steps), expected);
      });
    }
  });

  test('declares every emitted role', () {
    final result = notifier.buildSorting([5, 3, 8, 1, 9, 2, 7, 4, 6]);
    final emittedRoles = result.steps
        .expand((step) => step.marks.map((mark) => mark.role))
        .toSet();
    expect(emittedRoles.difference(notifier.roles), isEmpty);
  });

  group('algorithm information', () {
    test('has the expected complexity metadata', () {
      final complexity = notifier.algoComplexity;
      expect(complexity.name, StringsManager.bucketSort);
      expect(complexity.bestTimeComplexity, ONotationComplexity.nPlusK);
      expect(complexity.averageTimeComplexity, ONotationComplexity.nPlusK);
      expect(complexity.worstTimeComplexity, ONotationComplexity.n2);
      expect(complexity.spaceComplexity, ONotationComplexity.n);
      expect(complexity.stable, isTrue);
    });

    test('uses the Bucket Sort description', () {
      expect(
        notifier.algorithmDescription,
        StringsManager.bucketSortDescription,
      );
    });
  });
}

void _expectValidSteps(List<SortStep> steps, int length, Set<SortRole> roles) {
  for (final step in steps) {
    expect(step.a, inInclusiveRange(0, length - 1));
    if (step.b != -1) expect(step.b, inInclusiveRange(0, length - 1));
    expect(step.marks, isNotEmpty);
    for (final mark in step.marks) {
      expect(roles, contains(mark.role));
      expect(mark.start, inInclusiveRange(0, length - 1));
      expect(mark.end, inInclusiveRange(mark.start, length - 1));
    }
  }
}

List<int> _replay(List<int> input, List<SortStep> steps) {
  final values = List<int>.from(input);
  for (final step in steps) {
    if (step.kind == StepKind.swap) {
      final temporary = values[step.a];
      values[step.a] = values[step.b];
      values[step.b] = temporary;
    }
  }
  return values;
}
