import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sub_sorting/insertion_sort_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

import '../custom_expects.dart' show expectSortingSteps, expectStepShapes;

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

        expectSortingSteps(result.steps, [
          const SortStep(
            kind: StepKind.compare,
            a: 1,
            b: 0,
            marks: [
              RoleMark(role: SortRole.heldValue, start: 1, end: 1),
              RoleMark(role: SortRole.compare, start: 1, end: 1),
              RoleMark(role: SortRole.compare, start: 0, end: 0),
            ],
          ),
        ]);
      });

      test('items need swapping', () {
        final result = notifier.buildSorting([2, 1]);

        expect(result.sortedValues, [1, 2]);

        expectSortingSteps(result.steps, [
          const SortStep(
            kind: StepKind.compare,
            a: 1,
            b: 0,
            marks: [
              RoleMark(role: SortRole.heldValue, start: 1, end: 1),
              RoleMark(role: SortRole.compare, start: 1, end: 1),
              RoleMark(role: SortRole.compare, start: 0, end: 0),
            ],
          ),
          const SortStep(
            kind: StepKind.swap,
            a: 1,
            b: 0,
            marks: [
              RoleMark(role: SortRole.heldValue, start: 0, end: 0),
              RoleMark(role: SortRole.swap, start: 1, end: 1),
              RoleMark(role: SortRole.swap, start: 0, end: 0),
            ],
          ),
        ]);
      });
    });

    test('equal items', () {
      final result = notifier.buildSorting([5, 5]);

      expect(result.sortedValues, [5, 5]);

      expectSortingSteps(result.steps, [
        const SortStep(
          kind: StepKind.compare,
          a: 1,
          b: 0,
          marks: [
            RoleMark(role: SortRole.heldValue, start: 1, end: 1),
            RoleMark(role: SortRole.compare, start: 1, end: 1),
            RoleMark(role: SortRole.compare, start: 0, end: 0),
          ],
        ),
      ]);
    });

    test('mixed positive and negative items', () {
      final result = notifier.buildSorting([-1, 8, -4, 0, 1, 6, 2, 3]);

      expect(result.sortedValues, [-4, -1, 0, 1, 2, 3, 6, 8]);

      // Mark-level correctness is covered by the small cases above and the
      // role-subset test (C4.2); this pins the operation sequence.
      expectStepShapes(result.steps, const [
        (StepKind.compare, 1, 0),
        (StepKind.compare, 2, 1),
        (StepKind.swap, 2, 1),
        (StepKind.compare, 1, 0),
        (StepKind.swap, 1, 0),
        (StepKind.compare, 3, 2),
        (StepKind.swap, 3, 2),
        (StepKind.compare, 2, 1),
        (StepKind.compare, 4, 3),
        (StepKind.swap, 4, 3),
        (StepKind.compare, 3, 2),
        (StepKind.compare, 5, 4),
        (StepKind.swap, 5, 4),
        (StepKind.compare, 4, 3),
        (StepKind.compare, 6, 5),
        (StepKind.swap, 6, 5),
        (StepKind.compare, 5, 4),
        (StepKind.swap, 5, 4),
        (StepKind.compare, 4, 3),
        (StepKind.compare, 7, 6),
        (StepKind.swap, 7, 6),
        (StepKind.compare, 6, 5),
        (StepKind.swap, 6, 5),
        (StepKind.compare, 5, 4),
      ]);
    });

    test('repeated items', () {
      final result = notifier.buildSorting([4, 2, 3, 4, 1, 8, 1, 3, 3, 2]);

      expect(result.sortedValues, [1, 1, 2, 2, 3, 3, 3, 4, 4, 8]);
    });

    test('already sorted items', () {
      final result = notifier.buildSorting([-4, -1, 0, 1, 2, 3, 6]);

      expect(result.sortedValues, [-4, -1, 0, 1, 2, 3, 6]);

      expectStepShapes(result.steps, const [
        (StepKind.compare, 1, 0),
        (StepKind.compare, 2, 1),
        (StepKind.compare, 3, 2),
        (StepKind.compare, 4, 3),
        (StepKind.compare, 5, 4),
        (StepKind.compare, 6, 5),
      ]);
    });
  });

  test('every emitted RoleMark role is within the declared roles (C4.2)', () {
    final result = notifier.buildSorting([5, 3, 8, 1, 9, 2, 7, 4, 6]);
    final emittedRoles = result.steps.expand((s) => s.marks.map((m) => m.role)).toSet();
    expect(emittedRoles.difference(notifier.roles), isEmpty);
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
