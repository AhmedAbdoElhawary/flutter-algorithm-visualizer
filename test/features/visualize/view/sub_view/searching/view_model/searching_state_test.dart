import 'package:algorithm_visualizer/features/visualize/helper/playback_speed.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_constants.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_step.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/view_model/searching_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const first = PFStep(visited: {}, frontier: {1}, phase: PFPhase.exploring, metricA: 1);
  const last = PFStep(visited: {1}, frontier: {}, path: [1], phase: PFPhase.found, metricA: 0);

  test('starts with an empty grid, the default markers, and no run', () {
    final state = SearchingState.initial();

    expect(state.walls, hasLength(kPFRows));
    expect(state.walls.every((row) => row.length == kPFCols && !row.contains(true)), isTrue);
    expect(
      (state.startRow, state.startCol, state.endRow, state.endCol),
      (kPFStartRow, kPFStartCol, kPFEndRow, kPFEndCol),
    );
    expect(state.speed, PlaybackSpeed.normal);
    expect(state.playing, isFalse);
    expect(state.hasSteps, isFalse);
    expect(state.isAtStart, isTrue);
    expect(state.isAtEnd, isFalse);
    expect(state.currentStep, isNull);
  });

  test('emptyWalls gives a new grid each time', () {
    final a = SearchingState.emptyWalls();
    a[0][0] = true;

    expect(SearchingState.emptyWalls()[0][0], isFalse);
  });

  test('the step getters follow the index', () {
    final state = SearchingState.initial().copyWith(steps: const [first, last]);

    expect(state.hasSteps, isTrue);
    expect(state.currentStep, same(first));
    expect(state.isAtEnd, isFalse);

    final atEnd = state.copyWith(stepIndex: 1);
    expect(atEnd.currentStep, same(last));
    expect(atEnd.isAtStart, isFalse);
    expect(atEnd.isAtEnd, isTrue);
  });

  test('gridInput carries the walls and both markers', () {
    final state = SearchingState.initial().copyWith(startRow: 1, startCol: 2, endRow: 3, endCol: 4);
    final grid = state.gridInput;

    expect(grid.walls, same(state.walls));
    expect((grid.startRow, grid.startCol, grid.endRow, grid.endCol), (1, 2, 3, 4));
  });

  test('copyWith keeps what it is not given and changes what it is', () {
    final walls = SearchingState.emptyWalls();
    final state = SearchingState.initial().copyWith(steps: const [first]);

    expect(state.copyWith().steps, same(state.steps));
    final copy = state.copyWith(
      walls: walls,
      stepIndex: 0,
      playing: true,
      speed: PlaybackSpeed.fast5,
      startRow: 1,
      startCol: 1,
      endRow: 2,
      endCol: 2,
    );

    expect(copy.walls, same(walls));
    expect(copy.steps, same(state.steps));
    expect(copy.playing, isTrue);
    expect(copy.speed, PlaybackSpeed.fast5);
    expect((copy.startRow, copy.startCol, copy.endRow, copy.endCol), (1, 1, 2, 2));
  });

  test('clearSteps drops the run even when new steps are given', () {
    final state = SearchingState.initial().copyWith(steps: const [first]);

    expect(state.copyWith(clearSteps: true).steps, isNull);
    expect(state.copyWith(clearSteps: true, steps: const [last]).steps, isNull);
  });
}
