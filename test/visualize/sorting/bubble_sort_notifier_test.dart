import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sub_sorting/bubble_sort_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

import '../custom_expects.dart' show expectSortingSteps, expectStepShapes;

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
        test('already sorted', () {
          final result = notifier.buildSorting([1, 2]);

          expect(result.sortedValues, [1, 2]);

          expectSortingSteps(result.steps, [
            const SortStep(kind: StepKind.compare, a: 0, b: 1, marks: [
              RoleMark(role: SortRole.compare, start: 0, end: 0),
              RoleMark(role: SortRole.compare, start: 1, end: 1)
            ])
          ]);
        });

        test("equal items", () {
          final result = notifier.buildSorting([3, 3]);

          expect(result.sortedValues, [3, 3]);

          expectSortingSteps(result.steps, [
            const SortStep(kind: StepKind.compare, a: 0, b: 1, marks: [
              RoleMark(role: SortRole.compare, start: 0, end: 0),
              RoleMark(role: SortRole.compare, start: 1, end: 1)
            ]),
          ]);
        });
        test("positive items", () {
          final result = notifier.buildSorting([1, 0]);

          expect(result.sortedValues, [0, 1]);

          expectSortingSteps(result.steps, [
            const SortStep(kind: StepKind.compare, a: 0, b: 1, marks: [
              RoleMark(role: SortRole.compare, start: 0, end: 0),
              RoleMark(role: SortRole.compare, start: 1, end: 1)
            ]),
            const SortStep(kind: StepKind.swap, a: 0, b: 1, marks: [
              RoleMark(role: SortRole.swap, start: 0, end: 0),
              RoleMark(role: SortRole.swap, start: 1, end: 1)
            ]),
          ]);
        });

        test("negative items", () {
          final result = notifier.buildSorting([5, -1]);

          expect(result.sortedValues, [-1, 5]);
          expectSortingSteps(result.steps, [
            const SortStep(kind: StepKind.compare, a: 0, b: 1, marks: [
              RoleMark(role: SortRole.compare, start: 0, end: 0),
              RoleMark(role: SortRole.compare, start: 1, end: 1)
            ]),
            const SortStep(kind: StepKind.swap, a: 0, b: 1, marks: [
              RoleMark(role: SortRole.swap, start: 0, end: 0),
              RoleMark(role: SortRole.swap, start: 1, end: 1)
            ]),
          ]);
        });
      });

      test("random items for bubble sort", () {
        final result = notifier.buildSorting([-1, 8, -4, 0, 1, 6, 2, 3]);

        expect(result.sortedValues, [-4, -1, 0, 1, 2, 3, 6, 8]);

        // Mark-level correctness (the `sorted` span growing pass over pass)
        // is covered by the role-subset test in sort_role_test.dart and the
        // per-algorithm role tests (C4.2) — here we pin down the shape of
        // the operation sequence itself, which is what used to be wrong.
        expectStepShapes(result.steps, const [
          (StepKind.compare, 0, 1),
          (StepKind.compare, 1, 2),
          (StepKind.swap, 1, 2),
          (StepKind.compare, 2, 3),
          (StepKind.swap, 2, 3),
          (StepKind.compare, 3, 4),
          (StepKind.swap, 3, 4),
          (StepKind.compare, 4, 5),
          (StepKind.swap, 4, 5),
          (StepKind.compare, 5, 6),
          (StepKind.swap, 5, 6),
          (StepKind.compare, 6, 7),
          (StepKind.swap, 6, 7),
          (StepKind.compare, 0, 1),
          (StepKind.swap, 0, 1),
          (StepKind.compare, 1, 2),
          (StepKind.compare, 2, 3),
          (StepKind.compare, 3, 4),
          (StepKind.compare, 4, 5),
          (StepKind.swap, 4, 5),
          (StepKind.compare, 5, 6),
          (StepKind.swap, 5, 6),
          (StepKind.compare, 0, 1),
          (StepKind.compare, 1, 2),
          (StepKind.compare, 2, 3),
          (StepKind.compare, 3, 4),
          (StepKind.compare, 4, 5),
        ]);
      });

      test("repeated items for bubble sort", () {
        final result = notifier.buildSorting([4, 2, 3, 4, 1, 8, 1, 3, 3, 2]);

        expect(result.sortedValues, [1, 1, 2, 2, 3, 3, 3, 4, 4, 8]);
      });

      test("already sorted items for bubble sort", () {
        final result = notifier.buildSorting([-4, -1, 0, 1, 2, 3, 6]);

        expect(result.sortedValues, [-4, -1, 0, 1, 2, 3, 6]);
        expectSortingSteps(result.steps, [
          const SortStep(kind: StepKind.compare, a: 0, b: 1, marks: [
            RoleMark(role: SortRole.compare, start: 0, end: 0),
            RoleMark(role: SortRole.compare, start: 1, end: 1)
          ]),
          const SortStep(kind: StepKind.compare, a: 1, b: 2, marks: [
            RoleMark(role: SortRole.compare, start: 1, end: 1),
            RoleMark(role: SortRole.compare, start: 2, end: 2)
          ]),
          const SortStep(kind: StepKind.compare, a: 2, b: 3, marks: [
            RoleMark(role: SortRole.compare, start: 2, end: 2),
            RoleMark(role: SortRole.compare, start: 3, end: 3)
          ]),
          const SortStep(kind: StepKind.compare, a: 3, b: 4, marks: [
            RoleMark(role: SortRole.compare, start: 3, end: 3),
            RoleMark(role: SortRole.compare, start: 4, end: 4)
          ]),
          const SortStep(kind: StepKind.compare, a: 4, b: 5, marks: [
            RoleMark(role: SortRole.compare, start: 4, end: 4),
            RoleMark(role: SortRole.compare, start: 5, end: 5)
          ]),
          const SortStep(kind: StepKind.compare, a: 5, b: 6, marks: [
            RoleMark(role: SortRole.compare, start: 5, end: 5),
            RoleMark(role: SortRole.compare, start: 6, end: 6)
          ]),
        ]);
      });
    },
  );

  test('every emitted RoleMark role is within the declared roles (C4.2)', () {
    final result = notifier.buildSorting([5, 3, 8, 1, 9, 2, 7, 4, 6]);
    final emittedRoles = result.steps.expand((s) => s.marks.map((m) => m.role)).toSet();
    expect(emittedRoles.difference(notifier.roles), isEmpty);
  });

  group(
    "bubble sort information",
    () {
      test('algorithmComplexity for bubble sort', () {
        final complexity = notifier.algoComplexity;
        expect(complexity.name, StringsManager.bubbleSort);
        expect(complexity.bestTimeComplexity, ONotationComplexity.n);
        expect(complexity.averageTimeComplexity, ONotationComplexity.n2);
        expect(complexity.worstTimeComplexity, ONotationComplexity.n2);
        expect(complexity.spaceComplexity, ONotationComplexity.constant);
        expect(complexity.stable, isTrue);
      });

      test('algorithmDescription for bubble sort', () {
        final description = notifier.algorithmDescription;
        expect(description, StringsManager.bubbleSortDescription);
      });
    },
  );

  /// todo: codeSnippet and codeLineForStep are not implemented yet and not tested too
}
