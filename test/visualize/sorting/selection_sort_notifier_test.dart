import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sub_sorting/selection_sort_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

import '../custom_expects.dart';

void main() {
  late SelectionSortNotifier notifier;

  setUp(() {
    notifier = SelectionSortNotifier();
  });

  group('Test sorting for selection sort', () {
    test('empty items for selection sort', () {
      final result = notifier.buildSorting([]);

      expect(result.sortedValues, []);
      expect(result.steps, []);
    });

    group('one item for selection sort', () {
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

    group('two items for selection sort', () {
      test('items already sorted', () {
        final result = notifier.buildSorting([1, 2]);

        expect(result.sortedValues, [1, 2]);

        expectSortingSteps(result.steps, [
          SortingStep(index1: 0, index2: 0, action: SortingStatus.temporary),
          SortingStep(index1: 0, index2: 1, action: SortingStatus.compared),
          SortingStep(index1: 0, index2: 0, action: SortingStatus.sorted),
        ]);
      });

      test('items need swapping', () {
        final result = notifier.buildSorting([2, 1]);

        expect(result.sortedValues, [1, 2]);

        expectSortingSteps(result.steps, [
          SortingStep(index1: 0, index2: 0, action: SortingStatus.temporary),
          SortingStep(index1: 0, index2: 1, action: SortingStatus.compared),
          SortingStep(index1: 1, index2: 1, action: SortingStatus.temporary),
          SortingStep(index1: 0, index2: 1, action: SortingStatus.swapping),
          SortingStep(index1: 0, index2: 0, action: SortingStatus.sorted),
        ]);
      });
    });

    test('equal items', () {
      final result = notifier.buildSorting([5, 5]);

      expect(result.sortedValues, [5, 5]);

      expectSortingSteps(result.steps, [
        SortingStep(index1: 0, index2: 0, action: SortingStatus.temporary),
        SortingStep(index1: 0, index2: 1, action: SortingStatus.compared),
        SortingStep(index1: 0, index2: 0, action: SortingStatus.sorted),
      ]);
    });

    test('mixed positive and negative items', () {
      final result = notifier.buildSorting([-1, 8, -4, 0, 1, 6, 2, 3]);

      expect(result.sortedValues, [-4, -1, 0, 1, 2, 3, 6, 8]);

      expectSortingSteps(result.steps, [
        // i = 0
        SortingStep(index1: 0, index2: 0, action: SortingStatus.temporary),
        SortingStep(index1: 0, index2: 1, action: SortingStatus.compared),
        SortingStep(index1: 0, index2: 2, action: SortingStatus.compared),
        SortingStep(index1: 2, index2: 2, action: SortingStatus.temporary),
        SortingStep(index1: 2, index2: 3, action: SortingStatus.compared),
        SortingStep(index1: 2, index2: 4, action: SortingStatus.compared),
        SortingStep(index1: 2, index2: 5, action: SortingStatus.compared),
        SortingStep(index1: 2, index2: 6, action: SortingStatus.compared),
        SortingStep(index1: 2, index2: 7, action: SortingStatus.compared),
        SortingStep(index1: 0, index2: 2, action: SortingStatus.swapping),
        SortingStep(index1: 0, index2: 0, action: SortingStatus.sorted),

        // i = 1
        SortingStep(index1: 1, index2: 1, action: SortingStatus.temporary),
        SortingStep(index1: 1, index2: 2, action: SortingStatus.compared),
        SortingStep(index1: 2, index2: 2, action: SortingStatus.temporary),
        SortingStep(index1: 2, index2: 3, action: SortingStatus.compared),
        SortingStep(index1: 2, index2: 4, action: SortingStatus.compared),
        SortingStep(index1: 2, index2: 5, action: SortingStatus.compared),
        SortingStep(index1: 2, index2: 6, action: SortingStatus.compared),
        SortingStep(index1: 2, index2: 7, action: SortingStatus.compared),
        SortingStep(index1: 1, index2: 2, action: SortingStatus.swapping),
        SortingStep(index1: 1, index2: 1, action: SortingStatus.sorted),

        // i = 2
        SortingStep(index1: 2, index2: 2, action: SortingStatus.temporary),
        SortingStep(index1: 2, index2: 3, action: SortingStatus.compared),
        SortingStep(index1: 3, index2: 3, action: SortingStatus.temporary),
        SortingStep(index1: 3, index2: 4, action: SortingStatus.compared),
        SortingStep(index1: 3, index2: 5, action: SortingStatus.compared),
        SortingStep(index1: 3, index2: 6, action: SortingStatus.compared),
        SortingStep(index1: 3, index2: 7, action: SortingStatus.compared),
        SortingStep(index1: 2, index2: 3, action: SortingStatus.swapping),
        SortingStep(index1: 2, index2: 2, action: SortingStatus.sorted),

        // i = 3
        SortingStep(index1: 3, index2: 3, action: SortingStatus.temporary),
        SortingStep(index1: 3, index2: 4, action: SortingStatus.compared),
        SortingStep(index1: 4, index2: 4, action: SortingStatus.temporary),
        SortingStep(index1: 4, index2: 5, action: SortingStatus.compared),
        SortingStep(index1: 4, index2: 6, action: SortingStatus.compared),
        SortingStep(index1: 4, index2: 7, action: SortingStatus.compared),
        SortingStep(index1: 3, index2: 4, action: SortingStatus.swapping),
        SortingStep(index1: 3, index2: 3, action: SortingStatus.sorted),

        // i = 4
        SortingStep(index1: 4, index2: 4, action: SortingStatus.temporary),
        SortingStep(index1: 4, index2: 5, action: SortingStatus.compared),
        SortingStep(index1: 5, index2: 5, action: SortingStatus.temporary),
        SortingStep(index1: 5, index2: 6, action: SortingStatus.compared),
        SortingStep(index1: 6, index2: 6, action: SortingStatus.temporary),
        SortingStep(index1: 6, index2: 7, action: SortingStatus.compared),
        SortingStep(index1: 4, index2: 6, action: SortingStatus.swapping),
        SortingStep(index1: 4, index2: 4, action: SortingStatus.sorted),

        // i = 5
        SortingStep(index1: 5, index2: 5, action: SortingStatus.temporary),
        SortingStep(index1: 5, index2: 6, action: SortingStatus.compared),
        SortingStep(index1: 5, index2: 7, action: SortingStatus.compared),
        SortingStep(index1: 7, index2: 7, action: SortingStatus.temporary),
        SortingStep(index1: 5, index2: 7, action: SortingStatus.swapping),
        SortingStep(index1: 5, index2: 5, action: SortingStatus.sorted),

        // i = 6
        SortingStep(index1: 6, index2: 6, action: SortingStatus.temporary),
        SortingStep(index1: 6, index2: 7, action: SortingStatus.compared),
        SortingStep(index1: 7, index2: 7, action: SortingStatus.temporary),
        SortingStep(index1: 6, index2: 7, action: SortingStatus.swapping),
        SortingStep(index1: 6, index2: 6, action: SortingStatus.sorted),
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
        // i = 0
        SortingStep(index1: 0, index2: 0, action: SortingStatus.temporary),
        SortingStep(index1: 0, index2: 1, action: SortingStatus.compared),
        SortingStep(index1: 0, index2: 2, action: SortingStatus.compared),
        SortingStep(index1: 0, index2: 3, action: SortingStatus.compared),
        SortingStep(index1: 0, index2: 4, action: SortingStatus.compared),
        SortingStep(index1: 0, index2: 5, action: SortingStatus.compared),
        SortingStep(index1: 0, index2: 6, action: SortingStatus.compared),
        SortingStep(index1: 0, index2: 0, action: SortingStatus.sorted),

        // i = 1
        SortingStep(index1: 1, index2: 1, action: SortingStatus.temporary),
        SortingStep(index1: 1, index2: 2, action: SortingStatus.compared),
        SortingStep(index1: 1, index2: 3, action: SortingStatus.compared),
        SortingStep(index1: 1, index2: 4, action: SortingStatus.compared),
        SortingStep(index1: 1, index2: 5, action: SortingStatus.compared),
        SortingStep(index1: 1, index2: 6, action: SortingStatus.compared),
        SortingStep(index1: 1, index2: 1, action: SortingStatus.sorted),

        // i = 2
        SortingStep(index1: 2, index2: 2, action: SortingStatus.temporary),
        SortingStep(index1: 2, index2: 3, action: SortingStatus.compared),
        SortingStep(index1: 2, index2: 4, action: SortingStatus.compared),
        SortingStep(index1: 2, index2: 5, action: SortingStatus.compared),
        SortingStep(index1: 2, index2: 6, action: SortingStatus.compared),
        SortingStep(index1: 2, index2: 2, action: SortingStatus.sorted),

        // i = 3
        SortingStep(index1: 3, index2: 3, action: SortingStatus.temporary),
        SortingStep(index1: 3, index2: 4, action: SortingStatus.compared),
        SortingStep(index1: 3, index2: 5, action: SortingStatus.compared),
        SortingStep(index1: 3, index2: 6, action: SortingStatus.compared),
        SortingStep(index1: 3, index2: 3, action: SortingStatus.sorted),

        // i = 4
        SortingStep(index1: 4, index2: 4, action: SortingStatus.temporary),
        SortingStep(index1: 4, index2: 5, action: SortingStatus.compared),
        SortingStep(index1: 4, index2: 6, action: SortingStatus.compared),
        SortingStep(index1: 4, index2: 4, action: SortingStatus.sorted),

        // i = 5
        SortingStep(index1: 5, index2: 5, action: SortingStatus.temporary),
        SortingStep(index1: 5, index2: 6, action: SortingStatus.compared),
        SortingStep(index1: 5, index2: 5, action: SortingStatus.sorted),
      ]);
    });
  });

  group('algorithmComplexity for selection sort', () {
    final complexity = notifier.algoComplexity;

    test('name for selection sort', () {
      expect(complexity.name, StringsManager.selectionSort);
    });

    test('best time complexity for selection sort', () {
      expect(complexity.bestTimeComplexity, ONotationComplexity.n2);
    });

    test('average time complexity for selection sort', () {
      expect(complexity.averageTimeComplexity, ONotationComplexity.n2);
    });

    test('worst time complexity for selection sort', () {
      expect(complexity.worstTimeComplexity, ONotationComplexity.n2);
    });

    test('space complexity for selection sort', () {
      expect(complexity.spaceComplexity, ONotationComplexity.constant);
    });

    test('stability for selection sort', () {
      expect(complexity.stable, isTrue);
    });

    test('description for selection sort', () {
      final description = notifier.algorithmDescription;
      expect(description, StringsManager.selectionSortDescription);
    });
  });
}
