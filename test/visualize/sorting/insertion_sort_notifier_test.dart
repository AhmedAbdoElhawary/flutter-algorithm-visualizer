import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sub_sorting/insertion_sort_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

import 'custom_expects.dart' show expectSortingSteps;

void main() {
  late InsertionSortNotifier notifier;

  setUp(() {
    notifier = InsertionSortNotifier();
  });

  group('Test sorting for insertion sort', () {
    test('empty items for insertion sort', () {
      final result = notifier.buildSorting([]);

      expect(result.sortedValues, []);
      expect(result.steps, []);
    });

    group('one item for insertion sort', () {
      test('positive item', () {
        final result = notifier.buildSorting([1]);

        expect(result.sortedValues, [1]);
        expect(result.steps, []);
      });

      test('negative item', () {
        final result = notifier.buildSorting([-1]);

        expect(result.sortedValues, [-1]);
        expect(result.steps, []);
      });
    });

    group('two items for insertion sort', () {
      test('items already sorted', () {
        final result = notifier.buildSorting([1, 2]);

        expect(result.sortedValues, [1, 2]);

        expectSortingSteps(result.steps, [SortingStep(index1: 1, index2: 0, action: SortingStatus.compared)]);
      });

      test('items need swapping', () {
        final result = notifier.buildSorting([2, 1]);

        expect(result.sortedValues, [1, 2]);

        expectSortingSteps(result.steps, [
          SortingStep(index1: 1, index2: 0, action: SortingStatus.compared),
          SortingStep(index1: 1, index2: 0, action: SortingStatus.swapping),
        ]);
      });
    });

    test('equal items', () {
      final result = notifier.buildSorting([5, 5]);

      expect(result.sortedValues, [5, 5]);

      expectSortingSteps(result.steps, [
        SortingStep(index1: 1, index2: 0, action: SortingStatus.compared),
      ]);
    });

    test('mixed positive and negative items', () {
      final result = notifier.buildSorting([-1, 8, -4, 0, 1, 6, 2, 3]);

      expect(result.sortedValues, [-4, -1, 0, 1, 2, 3, 6, 8]);

      expectSortingSteps(result.steps, [
        SortingStep(index1: 1, index2: 0, action: SortingStatus.compared),
        SortingStep(index1: 2, index2: 1, action: SortingStatus.compared),
        SortingStep(index1: 2, index2: 1, action: SortingStatus.swapping),
        SortingStep(index1: 1, index2: 0, action: SortingStatus.compared),
        SortingStep(index1: 1, index2: 0, action: SortingStatus.swapping),
        SortingStep(index1: 3, index2: 2, action: SortingStatus.compared),
        SortingStep(index1: 3, index2: 2, action: SortingStatus.swapping),
        SortingStep(index1: 2, index2: 1, action: SortingStatus.compared),
        SortingStep(index1: 4, index2: 3, action: SortingStatus.compared),
        SortingStep(index1: 4, index2: 3, action: SortingStatus.swapping),
        SortingStep(index1: 3, index2: 2, action: SortingStatus.compared),
        SortingStep(index1: 5, index2: 4, action: SortingStatus.compared),
        SortingStep(index1: 5, index2: 4, action: SortingStatus.swapping),
        SortingStep(index1: 4, index2: 3, action: SortingStatus.compared),
        SortingStep(index1: 6, index2: 5, action: SortingStatus.compared),
        SortingStep(index1: 6, index2: 5, action: SortingStatus.swapping),
        SortingStep(index1: 5, index2: 4, action: SortingStatus.compared),
        SortingStep(index1: 5, index2: 4, action: SortingStatus.swapping),
        SortingStep(index1: 4, index2: 3, action: SortingStatus.compared),
        SortingStep(index1: 7, index2: 6, action: SortingStatus.compared),
        SortingStep(index1: 7, index2: 6, action: SortingStatus.swapping),
        SortingStep(index1: 6, index2: 5, action: SortingStatus.compared),
        SortingStep(index1: 6, index2: 5, action: SortingStatus.swapping),
        SortingStep(index1: 5, index2: 4, action: SortingStatus.compared),
      ]);
    });

    test('repeated items', () {
      final result = notifier.buildSorting([4, 2, 3, 4, 1, 8, 1, 3, 3, 2]);

      expect(result.sortedValues, [1, 1, 2, 2, 3, 3, 3, 4, 4, 8]);
    });

    test('already sorted items', () {
      final result = notifier.buildSorting([-4, -1, 0, 1, 2, 3, 6]);

      expect(result.sortedValues, [-4, -1, 0, 1, 2, 3, 6]);

      expectSortingSteps(result.steps, [
        SortingStep(index1: 1, index2: 0, action: SortingStatus.compared),
        SortingStep(index1: 2, index2: 1, action: SortingStatus.compared),
        SortingStep(index1: 3, index2: 2, action: SortingStatus.compared),
        SortingStep(index1: 4, index2: 3, action: SortingStatus.compared),
        SortingStep(index1: 5, index2: 4, action: SortingStatus.compared),
        SortingStep(index1: 6, index2: 5, action: SortingStatus.compared),
      ]);
    });
  });

  group(
    "insertion sort information",
    () {
      test('algorithmComplexity for insertion sort', () {
        final complexity = notifier.algoComplexity;
        expect(complexity.name, StringsManager.insertionSort);
        expect(complexity.bestTimeComplexity, ONotationComplexity.n);
        expect(complexity.averageTimeComplexity, ONotationComplexity.n2);
        expect(complexity.worstTimeComplexity, ONotationComplexity.n2);
        expect(complexity.spaceComplexity, ONotationComplexity.constant);
        expect(complexity.stable, isTrue);
      });

      test('algorithmDescription for insertion sort', () {
        final description = notifier.algorithmDescription;
        expect(description, StringsManager.insertionSortDescription);
      });
    },
  );
}
