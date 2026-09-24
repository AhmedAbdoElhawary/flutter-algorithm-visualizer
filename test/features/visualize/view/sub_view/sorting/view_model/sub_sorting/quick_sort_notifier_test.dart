import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sub_sorting/quick_sort_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late QuickSortNotifier notifier;

  setUp(() {
    notifier = QuickSortNotifier();
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
    });

    test('two elements already sorted', () {
      expect(notifier.buildSorting([1, 2]).sortedValues, [1, 2]);
    });

    test('two elements needing a swap', () {
      expect(notifier.buildSorting([2, 1]).sortedValues, [1, 2]);
    });

    test('random array', () {
      expect(notifier.buildSorting([-1, 8, -4, 0, 1, 6, 2, 3]).sortedValues, [-4, -1, 0, 1, 2, 3, 6, 8]);
    });

    test('duplicate-heavy array', () {
      expect(
        notifier.buildSorting([4, 2, 3, 4, 1, 8, 1, 3, 3, 2]).sortedValues,
        [1, 1, 2, 2, 3, 3, 3, 4, 4, 8],
      );
    });

    test('already sorted array (worst case for Lomuto)', () {
      expect(notifier.buildSorting([-4, -1, 0, 1, 2, 3, 6]).sortedValues, [-4, -1, 0, 1, 2, 3, 6]);
    });
  });

  test('no step is a no-op — the deleted padding step never comes back (C6.1, C6.3)', () {
    for (final input in [
      [-1, 8, -4, 0, 1, 6, 2, 3],
      [4, 2, 3, 4, 1, 8, 1, 3, 3, 2],
      [-4, -1, 0, 1, 2, 3, 6],
    ]) {
      final steps = notifier.buildSorting(input).steps;

      // Every step is a compare or a swap — nothing else (VR-9/C6.1).
      expect(steps.every((s) => s.kind == StepKind.compare || s.kind == StepKind.swap), isTrue);

      // No two consecutive steps are identical (VR-11/C6.3) — this is the
      // regression guard for the deleted no-op step, since that step used
      // to immediately follow its own compare with the same (a, b).
      for (int i = 1; i < steps.length; i++) {
        expect(steps[i], isNot(equals(steps[i - 1])));
      }
    }
  });

  test('swap never has a == b (VR-12)', () {
    final steps = notifier.buildSorting([-1, 8, -4, 0, 1, 6, 2, 3]).steps;
    for (final step in steps.where((s) => s.kind == StepKind.swap)) {
      expect(step.a, isNot(equals(step.b)));
    }
  });

  test('every emitted RoleMark role is within the declared roles (C4.2)', () {
    final result = notifier.buildSorting([5, 3, 8, 1, 9, 2, 7, 4, 6]);
    final emittedRoles = result.steps.expand((s) => s.marks.map((m) => m.role)).toSet();
    expect(emittedRoles.difference(notifier.roles), isEmpty);
  });

  group('algorithm information', () {
    test('algorithmComplexity for quick sort', () {
      final complexity = notifier.algoComplexity;
      expect(complexity.name, StringsManager.quickSort);
      expect(complexity.bestTimeComplexity, ONotationComplexity.nLogN);
      expect(complexity.averageTimeComplexity, ONotationComplexity.nLogN);
      expect(complexity.worstTimeComplexity, ONotationComplexity.n2);
      expect(complexity.spaceComplexity, ONotationComplexity.logN);
      expect(complexity.stable, isTrue);
    });

    test('algorithmDescription for quick sort', () {
      expect(notifier.algorithmDescription, StringsManager.quickSortDescription);
    });
  });
}
