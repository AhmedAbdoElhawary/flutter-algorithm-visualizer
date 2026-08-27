import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/features/base/view_model/algorithm_control_interface.dart';
import 'package:algorithm_visualizer/features/base/view_model/algorithm_description_interface.dart';
import 'package:algorithm_visualizer/features/visualize/helper/playback_speed.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

part '../helper/sortable_item.dart';
part '../helper/sorting_enums.dart';
part 'sorting_state.dart';

class _SortSnapshot {
  final List<SortableItem> list;
  final Map<int, Offset> positions;

  const _SortSnapshot(this.list, this.positions);
}

abstract class SortingNotifier extends Notifier<SortingNotifierState>
    implements AlgorithmDescriptionNotifier, AlgorithmControlInterface {
  static SortingNotifierState initState({List<SortableItem>? initialList}) {
    final list = initialList ?? _generateList(_defaultSize);
    final positions = _computeInitialPositions(list, _defaultSize);
    return SortingNotifierState(list: list, positions: positions);
  }

  @override
  SortingNotifierState build() {
    _snapshots = [];
    return initState();
  }

  static const ThemeEnum swappingColor = ThemeEnum.accentRed;
  static const ThemeEnum comparedColor = ThemeEnum.accentBlue;
  static const ThemeEnum itemColor = ThemeEnum.columnColor;
  static const ThemeEnum backgroundForSortingColor = ThemeEnum.backgroundForSortingColor;
  static const ThemeEnum doneSortingColor = ThemeEnum.accentGreen;
  static const ThemeEnum temporaryColor = ThemeEnum.pink;

  /// todo: add this feature that use dynamic size
  static const int _defaultSize = 10;
  static const int _maxSize = 15;
  static const int _minSize = 5;
  static double itemsPadding = 8.w;
  static double horizontalInsidePadding = 120.r;
  static const double bottomInsidePadding = 15;
  static double handleCentralBars = horizontalInsidePadding / 4;

  List<_SortSnapshot> _snapshots = [];

  bool _isPlayingFun = false;

  int _selectedAlgorithmLength = 1;
  int get selectedAlgorithmLength => _selectedAlgorithmLength;
  set selectedAlgorithmLength(int value) {
    if (value == selectedAlgorithmLength) return;
    _selectedAlgorithmLength = value;
  }

  @override
  PlaybackSpeed get getSpeed => state.speed;

  @override
  bool get isPlaying => state.isPlaying;
  @override
  bool get backwardValidation => state.isAtFirstStep;
  @override
  bool get forwardValidation => state.isAtLastStep;

  static List<SortableItem> _generateList(int size) {
    return List.generate(size, (index) => SortableItem(id: index, value: index + 1))..shuffle();
  }

  static double calculateItemWidth(int size) {
    final screenWidth = ScreenUtil().screenWidth - horizontalInsidePadding;
    final availableWidth = screenWidth - (itemsPadding * (size - 1));
    return availableWidth / size > 0 ? availableWidth / size : 1.0;
  }

  static double get calculateMaxListItemHeight {
    final screenHeight = ScreenUtil().screenHeight * 0.27;
    return screenHeight > 0 ? screenHeight : 1.0;
  }

  static (double actualHeight, String writtenHeight) calculateItemHeight(
    int itemIndex,
    int size,
    int selectedAlgorithmsLength,
  ) {
    final value = (calculateMaxListItemHeight / size) * (itemIndex + 1);
    final per = selectedAlgorithmsLength == 1
        ? 0.8
        : selectedAlgorithmsLength <= 2
            ? 0.9
            : selectedAlgorithmsLength <= 4
                ? 0.8
                : selectedAlgorithmsLength <= 6
                    ? 0.7
                    : 0.6;
    final height = value.h / selectedAlgorithmsLength * (per - 0.15);
    return (height, '${(height / 2).toInt()}');
  }

  String getWrittenHeight(int value) => calculateItemHeight(value, _size, selectedAlgorithmLength).$2;

  String statusText({
    required SortingStep? previousStep,
    required SortingStep? currentStep,
    required List<SortableItem> list,
  }) {
    if (state.isAllSorted) return StringsManager.arrayFullySorted;

    final initialText = StringsManager.initialArrayReadyToSort;
    if (currentStep == null || currentStep.index1 == -1 || currentStep.index2 == -1) return initialText;

    final value1 = list[currentStep.index1].value;
    final value2 = list[currentStep.index2].value;

    final writtenHeight1 = getWrittenHeight(value1);
    final writtenHeight2 = getWrittenHeight(value2);

    if (currentStep.action == SortingStatus.compared) {
      return '${StringsManager.compare} arr[${currentStep.index1}]=$writtenHeight1 ↔ arr[${currentStep.index2}]=$writtenHeight2';
    }

    if (currentStep.action == SortingStatus.swapping) {
      return '$writtenHeight2 > $writtenHeight1: ${StringsManager.swapPositions} ${currentStep.index1} ↔ ${currentStep.index2}';
    }

    return initialText;
  }

  Duration get _speedDuration => state.speed.stepSortingDuration;
  int get _size => state.size;

  SortingEnum get _getOperation => state.operationStatus;
  set _setOperation(SortingEnum value) => state = state.copyWith(operationStatus: value);

  void _initializePositions() {
    final positions = <int, Offset>{};
    final itemWidth = calculateItemWidth(_size);
    for (int i = 0; i < state.list.length; i++) {
      positions[state.list[i].id] = Offset(i * (itemWidth + itemsPadding), 0);
    }
    state = state.copyWith(isAllSorted: false, positions: positions);
    _snapshots = [];
  }

  static Map<int, Offset> _computeInitialPositions(List<SortableItem> list, int size) {
    final positions = <int, Offset>{};
    final itemWidth = calculateItemWidth(size);
    for (int i = 0; i < list.length; i++) {
      positions[list[i].id] = Offset(i * (itemWidth + itemsPadding), 0);
    }
    return positions;
  }

  @override
  void changeSpeed(PlaybackSpeed speed) {
    state = state.copyWith(isAllSorted: false, speed: speed);
  }

  void changeSize(double size) {
    if (_getOperation == SortingEnum.played) return;
    final newSize = _minSize + (_maxSize - _minSize) * size;
    state = state.copyWith(isAllSorted: false, size: newSize.toInt());
    reset();
  }

  void _resetItemColors() {
    final cleanList = state.list.map((item) => item.copyWith(sortedStatus: SortingStatus.none)).toList();
    state = state.copyWith(list: cleanList);
  }

  Future<void> cancelSorting() async {
    state = state.copyWith(
      list: _generateList(_size),
      operationStatus: SortingEnum.none,
      currentStep: SortingStep.noneStep(),
      totalPlaySteps: 0,
      sortedSteps: [],
      currentStepIndex: 0,
      isAllSorted: false,
    );
    _snapshots = [];
    _initializePositions();
  }

  Future<void> _stopSorting() async {
    _resetItemColors();
    state = state.copyWith(operationStatus: SortingEnum.stopped);
  }

  Future<void> _playSorting() async {
    _setOperation = SortingEnum.played;
    await _startSelectedSorting();
  }

  @override
  Future<void> togglePlay() async {
    if (state.isAtLastStep) {
      await reset();

      _playSorting();

      return;
    }

    final isPlaying = state.isPlaying;
    state = state.copyWith(operationStatus: isPlaying ? SortingEnum.stopped : SortingEnum.played);
    isPlaying ? _stopSorting() : _playSorting();
  }

  @override
  Future<void> reset() async {
    state = state.copyWith(
      list: _generateList(_size),
      operationStatus: SortingEnum.none,
      currentStep: SortingStep.noneStep(),
      totalPlaySteps: 0,
      sortedSteps: [],
      currentStepIndex: 0,
      isAllSorted: false,
    );
    _snapshots = [];
    _initializePositions();
  }

  @protected
  void ensureStepsGenerated() {
    if (state.sortedSteps.isNotEmpty) return;

    final values = state.list.map((e) => e.value).toList();
    final steps = buildSorting(values).steps;

    _snapshots = _computeSnapshots(state.list, state.positions, steps);

    state = state.copyWith(sortedSteps: steps, totalPlaySteps: steps.length);
  }

  List<_SortSnapshot> _computeSnapshots(
    List<SortableItem> initialList,
    Map<int, Offset> initialPositions,
    List<SortingStep> steps,
  ) {
    var list = List<SortableItem>.from(initialList);
    var positions = Map<int, Offset>.from(initialPositions);

    final snapshots = <_SortSnapshot>[_SortSnapshot(List.of(list), positions)];

    for (final step in steps) {
      list = list.map((e) => e.copyWith(sortedStatus: SortingStatus.none)).toList();

      if (step.action == SortingStatus.swapping) {
        list.swap(step.index1, step.index2);

        positions = Map<int, Offset>.from(positions);
        final id1 = list[step.index1].id;
        final id2 = list[step.index2].id;
        final tempPosition = positions[id1]!;
        positions[id1] = positions[id2]!;
        positions[id2] = tempPosition;
      }

      if (step.action == SortingStatus.compared || step.action == SortingStatus.swapping) {
        list[step.index1] = list[step.index1].copyWith(sortedStatus: step.action);
        list[step.index2] = list[step.index2].copyWith(sortedStatus: step.action);
      }

      snapshots.add(_SortSnapshot(List.of(list), positions));
    }

    return snapshots;
  }

  @override
  void stepForward() {
    if (state.isPlaying) return;

    ensureStepsGenerated();

    final steps = state.sortedSteps;
    final next = state.currentStepIndex + 1;
    if (next > steps.length) return;

    final snapshot = _snapshots[next];
    state = state.copyWith(
      list: snapshot.list,
      positions: snapshot.positions,
      currentStepIndex: next,
      currentStep: next > 0 ? steps[next - 1] : SortingStep.noneStep(),
    );

    if (next == steps.length) greenSortedItemsAsDone();
  }

  @override
  void stepBackward() {
    if (state.isPlaying) return;
    if (state.sortedSteps.isEmpty) return;

    final steps = state.sortedSteps;
    final prev = state.currentStepIndex - 1;
    if (prev < 0) return;

    final snapshot = _snapshots[prev];
    state = state.copyWith(
      list: snapshot.list,
      positions: snapshot.positions,
      currentStepIndex: prev,
      currentStep: prev > 0 ? steps[prev - 1] : SortingStep.noneStep(),
      isAllSorted: false,
    );
  }

  @protected
  Future<void> greenSortedItemsAsDone() async {
    final list = List<SortableItem>.from(state.list);
    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(sortedStatus: SortingStatus.sorted);
      state = state.copyWith(isAllSorted: true, list: List.of(list));
      await Future.delayed(state.speed.stepSortingDuration);
    }
  }

  Future<void> _startSelectedSorting() async {
    try {
      await updateVisualizeSorting();
    } catch (e) {
      /// TODO: create cancel variable and cancel it when dispose
      debugPrint("something wrong with sorting: $e");
    }
  }

  @protected
  Future<void> updateVisualizeSorting() async {
    if (_isPlayingFun) return;
    _isPlayingFun = true;

    ensureStepsGenerated();
    final steps = state.sortedSteps;

    final list = List<SortableItem>.from(state.list);
    Map<int, Offset> positions = Map<int, Offset>.from(state.positions);

    for (int i = state.currentStepIndex; i < steps.length; i++) {
      if (_getOperation != SortingEnum.played) {
        _isPlayingFun = false;
        return;
      }

      final step = steps[i];
      final prevStep = i > 0 ? steps[i - 1] : null;

      if (prevStep != null) {
        if (prevStep.index1 != step.index1) {
          list[prevStep.index1] = list[prevStep.index1].copyWith(sortedStatus: SortingStatus.none);
        }
        if (prevStep.index2 != step.index2) {
          list[prevStep.index2] = list[prevStep.index2].copyWith(sortedStatus: SortingStatus.none);
        }
      }

      switch (step.action) {
        case SortingStatus.compared:
          list[step.index1] = list[step.index1].copyWith(sortedStatus: SortingStatus.compared);
          list[step.index2] = list[step.index2].copyWith(sortedStatus: SortingStatus.compared);
          state = state.copyWith(list: List.of(list), positions: positions, currentStep: step);
          await Future.delayed(_speedDuration);
          break;

        case SortingStatus.swapping:
          list[step.index1] = list[step.index1].copyWith(sortedStatus: SortingStatus.swapping);
          list[step.index2] = list[step.index2].copyWith(sortedStatus: SortingStatus.swapping);
          list.swap(step.index1, step.index2);
          positions = Map<int, Offset>.from(positions);
          final id1 = list[step.index1].id;
          final id2 = list[step.index2].id;
          final tempPosition = positions[id1]!;
          positions[id1] = positions[id2]!;
          positions[id2] = tempPosition;
          state = state.copyWith(list: List.of(list), positions: positions, currentStep: step);
          await Future.delayed(_speedDuration);

          break;

        case SortingStatus.sorted:
          list[step.index1] = list[step.index1].copyWith(sortedStatus: SortingStatus.sorted);
          list[step.index2] = list[step.index2].copyWith(sortedStatus: SortingStatus.sorted);
          state = state.copyWith(list: List.of(list), positions: positions, currentStep: step);

          await Future.delayed(_speedDuration);

          break;

        case SortingStatus.temporary:
          list[step.index1] = list[step.index1].copyWith(sortedStatus: SortingStatus.temporary);
          list[step.index2] = list[step.index2].copyWith(sortedStatus: SortingStatus.temporary);
          state = state.copyWith(list: List.of(list), positions: positions, currentStep: step);

          await Future.delayed(_speedDuration);

          break;

        case SortingStatus.none:
          list[step.index1] = list[step.index1].copyWith(sortedStatus: SortingStatus.none);
          list[step.index2] = list[step.index2].copyWith(sortedStatus: SortingStatus.none);
          state = state.copyWith(list: List.of(list), positions: positions, currentStep: step);
          break;
      }

      await Future.delayed(_speedDuration);
      state = state.copyWith(currentStepIndex: i + 1);

      // clear the last color, as it became in his color until it's overwrite with green color
      if (i == steps.length - 1) {
        list[step.index1] = list[step.index1].copyWith(sortedStatus: SortingStatus.none);
        list[step.index2] = list[step.index2].copyWith(sortedStatus: SortingStatus.none);
        state = state.copyWith(list: List.of(list), positions: positions, currentStep: step);
        await Future.delayed(_speedDuration);
      }
    }

    state = state.copyWith(currentStepIndex: steps.length, currentStep: SortingStep.noneStep());
    await Future.delayed(_speedDuration);
    await greenSortedItemsAsDone();
    _isPlayingFun = false;
  }

  SortingResult buildSorting(List<int> values);
}
