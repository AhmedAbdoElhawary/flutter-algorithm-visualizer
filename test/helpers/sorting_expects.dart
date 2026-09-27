// it's better like that to compare the steps, and catch specific different step
import 'dart:math' as math;

import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

String _describe(SortStep step) {
  final marks = step.marks.map((m) => '${m.role.name}[${m.start}-${m.end}]').join(', ');
  return '${step.kind.name}(a=${step.a}, b=${step.b}, marks: {$marks})';
}

void _expectMatching<T>(
  List<SortStep> steps,
  List<T> expected,
  bool Function(SortStep actual, T expected) matches,
  String Function(T expected) describeExpected,
) {
  for (int i = 0; i < steps.length && i < expected.length; i++) {
    if (!matches(steps[i], expected[i])) {
      fail(
        'Step $i differs.\nExpected: ${describeExpected(expected[i])}\nActual:   ${_describe(steps[i])}',
      );
    }
  }

  expect(steps.length, expected.length);
}

void expectSortingSteps(List<SortStep> steps, List<SortStep> expectedSteps) {
  _expectMatching(steps, expectedSteps, (a, e) => a == e, _describe);
}

/// Checks only `(kind, a, b)` — for sequences long enough that hand-deriving
/// every persistent role mark would be its own source of error. Mark-level
/// correctness is covered by the per-algorithm role-subset and priority
/// tests instead (C4.2).
void expectStepShapes(List<SortStep> steps, List<(StepKind, int, int)> expected) {
  _expectMatching(
    steps,
    expected,
    (a, e) => a.kind == e.$1 && a.a == e.$2 && a.b == e.$3,
    (e) => '${e.$1}(a=${e.$2}, b=${e.$3})',
  );
}

/// 15 is the biggest list the size slider allows.
final sortingEdgeInputs = <String, List<int>>{
  'empty': [],
  '1 element': [7],
  '2 elements': [2, 1],
  'all equal': [4, 4, 4, 4, 4],
  'duplicates': [3, 1, 3, 2, 1, 3, 2],
  'already sorted': [1, 2, 3, 4, 5, 6],
  'reverse sorted': [6, 5, 4, 3, 2, 1],
  'the biggest list': List.generate(15, (i) => i + 1)..shuffle(math.Random(1)),
};

/// Checks the result, then replays the steps through the notifier the way the screen does. A sorter can
/// return the right values from steps that move the bars wrong, and only the replay catches that.
void sortingEdgeInputTests(SortingNotifier Function() create) {
  group('edge inputs', () {
    setUpAll(() {
      ScreenUtil.configure(
        data: const MediaQueryData(size: Size(390, 844)),
        designSize: const Size(390, 844),
        splitScreenMode: false,
        minTextAdapt: false,
      );
    });

    for (final MapEntry(key: name, value: input) in sortingEdgeInputs.entries) {
      test(name, () {
        final sorted = [...input]..sort();
        expect(create().buildSorting(input).sortedValues, sorted);

        SortingNotifier.debugInitialListOverride = [
          for (var i = 0; i < input.length; i++) SortableItem(id: i, value: input[i]),
        ];
        addTearDown(() => SortingNotifier.debugInitialListOverride = null);
        final provider = NotifierProvider<SortingNotifier, SortingNotifierState>(create);
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(provider.notifier)..stepForward();
        while (container.read(provider).currentStepIndex < container.read(provider).totalPlaySteps) {
          notifier.stepForward();
        }

        expect(container.read(provider).list.map((item) => item.value), sorted);
      });
    }
  });
}
