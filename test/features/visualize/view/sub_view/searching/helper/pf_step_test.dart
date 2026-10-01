import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_step.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a search is exploring, found, or exhausted', () {
    expect(PFPhase.values, [PFPhase.exploring, PFPhase.found, PFPhase.exhausted]);
  });

  test('path and metricB are empty unless given', () {
    const step = PFStep(visited: {1}, frontier: {2, 3}, phase: PFPhase.exploring, metricA: 2);

    expect(step.visited, {1});
    expect(step.frontier, {2, 3});
    expect(step.path, isNull);
    expect(step.metricA, 2);
    expect(step.metricB, isNull);
  });

  test('a found step carries its path and both metrics', () {
    const step = PFStep(visited: {1, 2}, frontier: {}, path: [1, 2], phase: PFPhase.found, metricA: 1, metricB: 0);

    expect(step.path, [1, 2]);
    expect(step.metricB, 0);
  });
}
