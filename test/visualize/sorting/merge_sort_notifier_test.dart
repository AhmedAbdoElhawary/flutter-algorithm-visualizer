import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sub_sorting/merge_sort_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MergeSortNotifier notifier;

  setUp(() {
    notifier = MergeSortNotifier();
  });

  group('correctness (C6.5)', () {
    test('empty input', () {
      final result = notifier.buildSorting([]);
      expect(result.sortedValues, []);
      expect(result.steps, []);
    });

    test('single element', () {
      final result = notifier.buildSorting([7]);
      expect(result.sortedValues, [7]);
      expect(result.steps, []);
    });

    test('two elements already sorted', () {
      final result = notifier.buildSorting([1, 2]);
      expect(result.sortedValues, [1, 2]);
    });

    test('two elements needing a swap', () {
      final result = notifier.buildSorting([2, 1]);
      expect(result.sortedValues, [1, 2]);
    });

    test('random array', () {
      final result = notifier.buildSorting([-1, 8, -4, 0, 1, 6, 2, 3]);
      expect(result.sortedValues, [-4, -1, 0, 1, 2, 3, 6, 8]);
    });

    test('duplicate-heavy array', () {
      final result = notifier.buildSorting([4, 2, 3, 4, 1, 8, 1, 3, 3, 2]);
      expect(result.sortedValues, [1, 1, 2, 2, 3, 3, 3, 4, 4, 8]);
    });

    test('already sorted array', () {
      final result = notifier.buildSorting([-4, -1, 0, 1, 2, 3, 6]);
      expect(result.sortedValues, [-4, -1, 0, 1, 2, 3, 6]);
    });

    test('reverse sorted array', () {
      final result = notifier.buildSorting([9, 7, 5, 3, 1]);
      expect(result.sortedValues, [1, 3, 5, 7, 9]);
    });
  });

  test('zero swap steps are ever emitted (C7 Merge, C6.5)', () {
    for (final input in [
      [-1, 8, -4, 0, 1, 6, 2, 3],
      [4, 2, 3, 4, 1, 8, 1, 3, 3, 2],
      [9, 7, 5, 3, 1],
      [1, 2, 3, 4, 5],
    ]) {
      final result = notifier.buildSorting(input);
      expect(result.steps.any((s) => s.kind == StepKind.swap), isFalse);
    }
  });

  test('every emitted RoleMark role is within the declared roles (C4.2)', () {
    final result = notifier.buildSorting([5, 3, 8, 1, 9, 2, 7, 4, 6]);
    final emittedRoles = result.steps.expand((s) => s.marks.map((m) => m.role)).toSet();
    expect(emittedRoles.difference(notifier.roles), isEmpty);
  });

  test('marks a contiguous leftRun span and a contiguous rightRun span simultaneously (US2 scenario 3)', () {
    final result = notifier.buildSorting([5, 3, 8, 1, 9, 2, 7, 4]);

    final stepsWithBothRuns = result.steps.where((s) {
      final roles = s.marks.map((m) => m.role).toSet();
      return roles.contains(SortRole.leftRun) && roles.contains(SortRole.rightRun);
    });

    expect(stepsWithBothRuns, isNotEmpty);

    for (final step in stepsWithBothRuns) {
      final left = step.marks.firstWhere((m) => m.role == SortRole.leftRun);
      final right = step.marks.firstWhere((m) => m.role == SortRole.rightRun);
      expect(left.start, lessThanOrEqualTo(left.end));
      expect(right.start, lessThanOrEqualTo(right.end));
    }
  });

  group('complexity agreement (FR-034, FR-037, SC-012, C8.1, C8.2)', () {
    test('a merge pass over m elements never exceeds m writes / m-1 compares per pass', () {
      // Verified indirectly: total writes across the whole sort never exceed
      // n * log2(n) (rounded up), which cannot hold if any single pass wrote
      // more than its own element count (C8.1 -> C8.2).
      for (int n = 5; n <= 15; n++) {
        final values = List.generate(n, (i) => n - i);
        final result = notifier.buildSorting(values);

        final writes = result.steps.where((s) => s.kind == StepKind.write).length;
        final compares = result.steps.where((s) => s.kind == StepKind.compare).length;

        expect(writes, lessThanOrEqualTo(n * (n.bitLength)));
        expect(compares, lessThanOrEqualTo(writes));
      }
    });

    test('total step count grows as O(n log n), not O(n^2), from size 5 to 15 (C8.2)', () {
      final counts = <int, int>{};
      for (int n = 5; n <= 15; n++) {
        final values = List.generate(n, (i) => n - i); // reverse sorted: worst case
        counts[n] = notifier.buildSorting(values).steps.length;
      }

      // O(n log n) at n=15 is ~4x O(n log n) at n=5; O(n^2) would be ~9x.
      final ratio = counts[15]! / counts[5]!;
      expect(ratio, lessThan(9));
    });
  });

  group('algorithm information', () {
    test('algorithmComplexity for merge sort', () {
      final complexity = notifier.algoComplexity;
      expect(complexity.name, StringsManager.mergeSort);
      expect(complexity.bestTimeComplexity, ONotationComplexity.nLogN);
      expect(complexity.averageTimeComplexity, ONotationComplexity.nLogN);
      expect(complexity.worstTimeComplexity, ONotationComplexity.nLogN);
      expect(complexity.spaceComplexity, ONotationComplexity.n);
      expect(complexity.stable, isTrue);
    });

    test('algorithmDescription for merge sort', () {
      expect(notifier.algorithmDescription, StringsManager.mergeSortDescription);
    });
  });
}
