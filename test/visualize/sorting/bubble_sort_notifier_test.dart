import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sub_sorting/bubble_sort_notifier.dart';
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late BubbleSortNotifier notifier;

  setUp(() {
    notifier = BubbleSortNotifier();
  });

  group(
    "Test sorting for bubble sort",
    () {
      test("empty items for bubble sort", () {
        final result = notifier.buildSorting([]);

        expect(result.sortedValues, []);
        expect(result.steps, []);
      });
      group("one item for bubble sort", () {
        test("positive item", () {
          final result = notifier.buildSorting([1]);

          expect(result.sortedValues, [1]);
          // no steps to sorting it
          expect(result.steps, []);
        });

        test("negative item", () {
          final result = notifier.buildSorting([-1]);

          expect(result.sortedValues, [-1]);
          // no steps to sorting it
          expect(result.steps, []);
        });
      });

      group("two items for bubble sort", () {
        test("positive items", () {
          final result = notifier.buildSorting([1, 0]);

          expect(result.sortedValues, [0, 1]);

          _expectSteps(result.steps, [
            SortingStep(index1: 0, index2: 1, action: SortingStatus.compared),
            SortingStep(index1: 0, index2: 1, action: SortingStatus.swapping),
          ]);
        });

        test("negative items", () {
          final result = notifier.buildSorting([5, -1]);

          expect(result.sortedValues, [-1, 5]);
          _expectSteps(result.steps, [
            SortingStep(index1: 0, index2: 1, action: SortingStatus.compared),
            SortingStep(index1: 0, index2: 1, action: SortingStatus.swapping),
          ]);
        });
      });

      test("random items for bubble sort", () {
        final result = notifier.buildSorting([-1, 8, -4, 0, 1, 6, 2, 3]);

        expect(result.sortedValues, [-4, -1, 0, 1, 2, 3, 6, 8]);

        _expectSteps(result.steps, [
          //   0   1  2  3  4  5  6  7
          // [-1, 8, -4, 0, 1, 6, 2, 3]
          SortingStep(index1: 0, index2: 1, action: SortingStatus.compared),

          SortingStep(index1: 1, index2: 2, action: SortingStatus.compared),
          SortingStep(index1: 1, index2: 2, action: SortingStatus.swapping),
          //   0   1  2  3  4  5  6  7
          // [-1, -4, 8, 0, 1, 6, 2, 3]

          SortingStep(index1: 2, index2: 3, action: SortingStatus.compared),
          SortingStep(index1: 2, index2: 3, action: SortingStatus.swapping),
          //   0   1  2  3  4  5  6  7
          // [-1, -4, 0, 8, 1, 6, 2, 3]

          SortingStep(index1: 3, index2: 4, action: SortingStatus.compared),
          SortingStep(index1: 3, index2: 4, action: SortingStatus.swapping),
          //   0   1  2  3  4  5  6  7
          // [-1, -4, 0, 1, 8, 6, 2, 3]

          SortingStep(index1: 4, index2: 5, action: SortingStatus.compared),
          SortingStep(index1: 4, index2: 5, action: SortingStatus.swapping),
          //   0   1  2  3  4  5  6  7
          // [-1, -4, 0, 1, 6, 8, 2, 3]

          SortingStep(index1: 5, index2: 6, action: SortingStatus.compared),
          SortingStep(index1: 5, index2: 6, action: SortingStatus.swapping),
          //   0   1  2  3  4  5  6  7
          // [-1, -4, 0, 1, 6, 2, 8, 3]

          SortingStep(index1: 6, index2: 7, action: SortingStatus.compared),
          SortingStep(index1: 6, index2: 7, action: SortingStatus.swapping),
          //   0   1  2  3  4  5  6  7
          // [-1, -4, 0, 1, 6, 2, 3, 8]

          SortingStep(index1: 0, index2: 1, action: SortingStatus.compared),
          SortingStep(index1: 0, index2: 1, action: SortingStatus.swapping),
          //   0   1  2  3  4  5  6  7
          // [-4, -1, 0, 1, 6, 2, 3, 8]

          SortingStep(index1: 1, index2: 2, action: SortingStatus.compared),
          SortingStep(index1: 2, index2: 3, action: SortingStatus.compared),
          SortingStep(index1: 3, index2: 4, action: SortingStatus.compared),

          SortingStep(index1: 4, index2: 5, action: SortingStatus.compared),
          SortingStep(index1: 4, index2: 5, action: SortingStatus.swapping),
          //   0   1  2  3  4  5  6  7
          // [-4, -1, 0, 1, 2, 6, 3, 8]

          SortingStep(index1: 5, index2: 6, action: SortingStatus.compared),
          SortingStep(index1: 5, index2: 6, action: SortingStatus.swapping),
          //   0   1  2  3  4  5  6  7
          // [-4, -1, 0, 1, 2, 3, 6, 8]

          SortingStep(index1: 0, index2: 1, action: SortingStatus.compared),
          SortingStep(index1: 1, index2: 2, action: SortingStatus.compared),
          SortingStep(index1: 2, index2: 3, action: SortingStatus.compared),
          SortingStep(index1: 3, index2: 4, action: SortingStatus.compared),
          SortingStep(index1: 4, index2: 5, action: SortingStatus.compared),
        ]);
      });

      test("repeated items for bubble sort", () {
        final result = notifier.buildSorting([4, 2, 3, 4, 1, 8, 1, 3, 3, 2]);

        expect(result.sortedValues, [1, 1, 2, 2, 3, 3, 3, 4, 4, 8]);
      });

      test("already sorted items for bubble sort", () {
        final result = notifier.buildSorting([-4, -1, 0, 1, 2, 3, 6]);

        expect(result.sortedValues, [-4, -1, 0, 1, 2, 3, 6]);
        _expectSteps(result.steps, [
          SortingStep(index1: 0, index2: 1, action: SortingStatus.compared),
          SortingStep(index1: 1, index2: 2, action: SortingStatus.compared),
          SortingStep(index1: 2, index2: 3, action: SortingStatus.compared),
          SortingStep(index1: 3, index2: 4, action: SortingStatus.compared),
          SortingStep(index1: 4, index2: 5, action: SortingStatus.compared),
          SortingStep(index1: 5, index2: 6, action: SortingStatus.compared),
        ]);
      });
    },
  );

  test('algorithmComplexity reports expected Big-O characteristics', () {
    final complexity = notifier.algoComplexity;
    expect(complexity.bestTimeComplexity, ONotationComplexity.n);
    expect(complexity.averageTimeComplexity, ONotationComplexity.n2);
    expect(complexity.worstTimeComplexity, ONotationComplexity.n2);
    expect(complexity.spaceComplexity, ONotationComplexity.constant);
    expect(complexity.stable, isTrue);
  });

  /// todo: codeSnippet and codeLineForStep are not implemented yet and not tested too
}

void _expectSteps(List<SortingStep> steps, List<SortingStep> expectedSteps) {
  final check =
      steps.whereIndexed((index, element) => element == expectedSteps[index]).length == expectedSteps.length;
  expect(check, isTrue);
}
