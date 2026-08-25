// it's better like that to compare the steps, and catch specific different step
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:flutter_test/flutter_test.dart' show expect;

void expectSortingSteps(List<SortingStep> steps, List<SortingStep> expectedSteps) {
  expect(steps.length, expectedSteps.length);

  for (int i = 0; i < steps.length; i++) {
    expect(steps[i].toMap, expectedSteps[i].toMap);
  }
}
