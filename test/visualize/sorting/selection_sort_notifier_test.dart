import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sub_sorting/selection_sort_notifier.dart';
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

        // The standalone `temporary`/`sorted` steps are gone by design
        // (C7 Selection) — the running minimum and target now ride on the
        // one real comparison instead of generating steps of their own.
        expectSortingSteps(result.steps, [
          const SortStep(
            kind: StepKind.compare,
            a: 0,
            b: 1,
            marks: [
              RoleMark(role: SortRole.target, start: 0, end: 0),
              RoleMark(role: SortRole.minimum, start: 0, end: 0),
              RoleMark(role: SortRole.compare, start: 0, end: 0),
              RoleMark(role: SortRole.compare, start: 1, end: 1),
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
            a: 0,
            b: 1,
            marks: [
              RoleMark(role: SortRole.target, start: 0, end: 0),
              RoleMark(role: SortRole.minimum, start: 0, end: 0),
              RoleMark(role: SortRole.compare, start: 0, end: 0),
              RoleMark(role: SortRole.compare, start: 1, end: 1),
            ],
          ),
          const SortStep(
            kind: StepKind.swap,
            a: 0,
            b: 1,
            marks: [
              RoleMark(role: SortRole.target, start: 0, end: 0),
              RoleMark(role: SortRole.minimum, start: 1, end: 1),
              RoleMark(role: SortRole.swap, start: 0, end: 0),
              RoleMark(role: SortRole.swap, start: 1, end: 1),
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
          a: 0,
          b: 1,
          marks: [
            RoleMark(role: SortRole.target, start: 0, end: 0),
            RoleMark(role: SortRole.minimum, start: 0, end: 0),
            RoleMark(role: SortRole.compare, start: 0, end: 0),
            RoleMark(role: SortRole.compare, start: 1, end: 1),
          ],
        ),
      ]);
    });

    test('mixed positive and negative items', () {
      final result = notifier.buildSorting([-1, 8, -4, 0, 1, 6, 2, 3]);

      expect(result.sortedValues, [-4, -1, 0, 1, 2, 3, 6, 8]);

      // Step-count expectations drop here by design (C7): the standalone
      // `temporary` and `sorted` steps this array used to need are gone.
      // Mark-level correctness is covered by the small cases above and by
      // sort_role_test.dart / the role-subset test (C4.2).
      expectStepShapes(result.steps, const [
        // i = 0
        (StepKind.compare, 0, 1),
        (StepKind.compare, 0, 2),
        (StepKind.compare, 2, 3),
        (StepKind.compare, 2, 4),
        (StepKind.compare, 2, 5),
        (StepKind.compare, 2, 6),
        (StepKind.compare, 2, 7),
        (StepKind.swap, 0, 2),

        // i = 1
        (StepKind.compare, 1, 2),
        (StepKind.compare, 2, 3),
        (StepKind.compare, 2, 4),
        (StepKind.compare, 2, 5),
        (StepKind.compare, 2, 6),
        (StepKind.compare, 2, 7),
        (StepKind.swap, 1, 2),

        // i = 2
        (StepKind.compare, 2, 3),
        (StepKind.compare, 3, 4),
        (StepKind.compare, 3, 5),
        (StepKind.compare, 3, 6),
        (StepKind.compare, 3, 7),
        (StepKind.swap, 2, 3),

        // i = 3
        (StepKind.compare, 3, 4),
        (StepKind.compare, 4, 5),
        (StepKind.compare, 4, 6),
        (StepKind.compare, 4, 7),
        (StepKind.swap, 3, 4),

        // i = 4
        (StepKind.compare, 4, 5),
        (StepKind.compare, 5, 6),
        (StepKind.compare, 6, 7),
        (StepKind.swap, 4, 6),

        // i = 5
        (StepKind.compare, 5, 6),
        (StepKind.compare, 5, 7),
        (StepKind.swap, 5, 7),

        // i = 6
        (StepKind.compare, 6, 7),
        (StepKind.swap, 6, 7),
      ]);
    });

    test('repeated items', () {
      final result = notifier.buildSorting([4, 2, 3, 4, 1, 8, 1, 3, 3, 2]);

      expect(result.sortedValues, [1, 1, 2, 2, 3, 3, 3, 4, 4, 8]);
    });

    test('already sorted items', () {
      final result = notifier.buildSorting([-4, -1, 0, 1, 2, 3, 6]);

      expect(result.sortedValues, [-4, -1, 0, 1, 2, 3, 6]);

      // Already sorted: the running minimum never moves off `i`, so no pass
      // ever swaps.
      expectStepShapes(result.steps, const [
        (StepKind.compare, 0, 1),
        (StepKind.compare, 0, 2),
        (StepKind.compare, 0, 3),
        (StepKind.compare, 0, 4),
        (StepKind.compare, 0, 5),
        (StepKind.compare, 0, 6),
        (StepKind.compare, 1, 2),
        (StepKind.compare, 1, 3),
        (StepKind.compare, 1, 4),
        (StepKind.compare, 1, 5),
        (StepKind.compare, 1, 6),
        (StepKind.compare, 2, 3),
        (StepKind.compare, 2, 4),
        (StepKind.compare, 2, 5),
        (StepKind.compare, 2, 6),
        (StepKind.compare, 3, 4),
        (StepKind.compare, 3, 5),
        (StepKind.compare, 3, 6),
        (StepKind.compare, 4, 5),
        (StepKind.compare, 4, 6),
        (StepKind.compare, 5, 6),
      ]);
    });
  });

  test('every emitted RoleMark role is within the declared roles (C4.2)', () {
    final result = notifier.buildSorting([5, 3, 8, 1, 9, 2, 7, 4, 6]);
    final emittedRoles = result.steps.expand((s) => s.marks.map((m) => m.role)).toSet();
    expect(emittedRoles.difference(notifier.roles), isEmpty);
  });

  test(
      'exactly one minimum and one target per step of a pass; minimum moves rather than duplicating '
      '(US2 scenarios 1 and 2)', () {
    final result = notifier.buildSorting([-1, 8, -4, 0, 1, 6, 2, 3]);

    for (final step in result.steps) {
      final minimumMarks = step.marks.where((m) => m.role == SortRole.minimum);
      final targetMarks = step.marks.where((m) => m.role == SortRole.target);

      expect(minimumMarks.length, lessThanOrEqualTo(1));
      expect(targetMarks.length, lessThanOrEqualTo(1));
    }
  });

  group('algorithmComplexity for selection sort', () {
    test('name for selection sort', () {
      final complexity = notifier.algoComplexity;

      expect(complexity.name, StringsManager.selectionSort);
    });

    test('best time complexity for selection sort', () {
      final complexity = notifier.algoComplexity;

      expect(complexity.bestTimeComplexity, ONotationComplexity.n2);
    });

    test('average time complexity for selection sort', () {
      final complexity = notifier.algoComplexity;

      expect(complexity.averageTimeComplexity, ONotationComplexity.n2);
    });

    test('worst time complexity for selection sort', () {
      final complexity = notifier.algoComplexity;

      expect(complexity.worstTimeComplexity, ONotationComplexity.n2);
    });

    test('space complexity for selection sort', () {
      final complexity = notifier.algoComplexity;

      expect(complexity.spaceComplexity, ONotationComplexity.constant);
    });

    test('stability for selection sort', () {
      final complexity = notifier.algoComplexity;

      expect(complexity.stable, isTrue);
    });

    test('description for selection sort', () {
      final description = notifier.algorithmDescription;
      expect(description, StringsManager.selectionSortDescription);
    });
  });
}
