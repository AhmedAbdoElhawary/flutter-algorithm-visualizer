// it's better like that to compare the steps, and catch specific different step
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:flutter_test/flutter_test.dart' show expect, fail;

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
