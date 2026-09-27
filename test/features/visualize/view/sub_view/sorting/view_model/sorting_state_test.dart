import 'package:algorithm_visualizer/features/visualize/helper/playback_speed.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final list = [SortableItem(id: 0, value: 2), SortableItem(id: 1, value: 1)];
  const step = SortStep(kind: StepKind.compare, a: 0, b: 1, marks: []);

  test('starts idle at step 0 with nothing to show', () {
    final state = SortingNotifierState(list: list);

    expect(state.operationStatus, SortingEnum.none);
    expect(state.size, 9);
    expect(state.speed, PlaybackSpeed.normal);
    expect(state.isPlaying, isFalse);
    expect(state.isAtFirstStep, isTrue);
    expect(state.isAtLastStep, isFalse, reason: 'no steps yet is not the end');
    expect(state.progressValue, 0);
    expect(state.progressLabel, '');
  });

  test('progress follows the current step', () {
    final state = SortingNotifierState(list: list, totalPlaySteps: 4, currentStepIndex: 1);

    expect(state.progressValue, 0.25);
    expect(state.progressLabel, 'Step 1 of 4');
    expect(state.isAtFirstStep, isFalse);
    expect(state.isAtLastStep, isFalse);
    expect(state.copyWith(currentStepIndex: 4).isAtLastStep, isTrue);
  });

  test('isPlaying only while played', () {
    final state = SortingNotifierState(list: list);

    expect(state.copyWith(operationStatus: SortingEnum.played).isPlaying, isTrue);
    expect(state.copyWith(operationStatus: SortingEnum.stopped).isPlaying, isFalse);
  });

  test('copyWith keeps every field it is not given', () {
    final state = SortingNotifierState(
      list: list,
      operationStatus: SortingEnum.stopped,
      size: 12,
      speed: PlaybackSpeed.fast5,
      isAllSorted: true,
      positions: const {0: Offset(1, 2)},
      sortedSteps: const [step],
      currentStepIndex: 1,
      totalPlaySteps: 1,
      currentStep: step,
      rolePerIndex: const [SortRole.sorted, SortRole.idle],
    );

    final copy = state.copyWith();

    expect(copy.list, same(state.list));
    expect(copy.operationStatus, SortingEnum.stopped);
    expect(copy.size, 12);
    expect(copy.speed, PlaybackSpeed.fast5);
    expect(copy.isAllSorted, isTrue);
    expect(copy.positions, same(state.positions));
    expect(copy.sortedSteps, same(state.sortedSteps));
    expect(copy.currentStepIndex, 1);
    expect(copy.totalPlaySteps, 1);
    expect(copy.currentStep, step);
    expect(copy.rolePerIndex, same(state.rolePerIndex));
  });

  test('copyWith changes what it is given', () {
    final other = [SortableItem(id: 5, value: 5)];
    final copy = SortingNotifierState(list: list).copyWith(
      list: other,
      operationStatus: SortingEnum.played,
      size: 5,
      speed: PlaybackSpeed.slow,
      isAllSorted: true,
      positions: const {5: Offset.zero},
      sortedSteps: const [step],
      currentStepIndex: 1,
      totalPlaySteps: 1,
      currentStep: step,
      rolePerIndex: const [SortRole.sorted],
    );

    expect(copy.list, same(other));
    expect(copy.operationStatus, SortingEnum.played);
    expect(copy.size, 5);
    expect(copy.speed, PlaybackSpeed.slow);
    expect(copy.isAllSorted, isTrue);
    expect(copy.positions, const {5: Offset.zero});
    expect(copy.sortedSteps, const [step]);
    expect(copy.currentStepIndex, 1);
    expect(copy.totalPlaySteps, 1);
    expect(copy.currentStep, step);
    expect(copy.rolePerIndex, const [SortRole.sorted]);
  });

  test('clearCurrentStep empties the step even when a new one is given', () {
    final state = SortingNotifierState(list: list, currentStep: step);

    expect(state.copyWith(clearCurrentStep: true).currentStep, isNull);
    expect(state.copyWith(clearCurrentStep: true, currentStep: step).currentStep, isNull);
  });
}
