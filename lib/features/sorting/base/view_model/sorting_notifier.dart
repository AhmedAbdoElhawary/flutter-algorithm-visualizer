import 'package:algorithm_visualizer/core/helpers/playback_speed.dart';
import 'package:algorithm_visualizer/core/helpers/screen_size.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/features/base/view_model/algorithm_control_interface.dart';
import 'package:algorithm_visualizer/features/base/view_model/algorithm_description_interface.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

part 'sorting_state.dart';
part '../helper/sorting_enums.dart';
part '../helper/sortable_item.dart';

abstract class SortingNotifier extends StateNotifier<SortingNotifierState>
    implements AlgorithmDescriptionNotifier, AlgorithmControlInterface {
  SortingNotifier() : super(SortingNotifierState(list: _generateList(_defaultSize))) {
    _initializePositions();
  }

  static const ThemeEnum swappingColor = ThemeEnum.redColor;
  static const ThemeEnum comparedColor = ThemeEnum.lightBlueColor;
  static const ThemeEnum itemColor = ThemeEnum.columnColor;
  static const ThemeEnum backgroundForSortingColor = ThemeEnum.backgroundForSortingColor;
  static const ThemeEnum doneSortingColor = ThemeEnum.greenColor;

  static const int _defaultSize = 7;
  static const int _maxSize = 15;
  static const int _minSize = 5;
  static double itemsPadding = 8.w;
  static double horizontalInsidePadding = 120.r;
  static const double bottomInsidePadding = 15;
  static double handleCentralBars = horizontalInsidePadding / 4;

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

  static double calculateItemWidth(BuildContext context, int size) {
    final screenWidth = MediaQuery.of(context).size.width - horizontalInsidePadding;
    final availableWidth = screenWidth - (itemsPadding * (size - 1));
    return availableWidth / size > 0 ? availableWidth / size : 1.0;
  }

  static double calculateMaxListItemHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height * 0.27;
    return screenHeight > 0 ? screenHeight : 1.0;
  }

  static double calculateItemHeight(
    BuildContext context,
    int itemIndex,
    int size,
    int selectedAlgorithmsLength,
  ) {
    final value = (calculateMaxListItemHeight(context) / size) * (itemIndex + 1);
    final per = selectedAlgorithmsLength == 1
        ? 0.8
        : selectedAlgorithmsLength <= 2
            ? 0.9
            : selectedAlgorithmsLength <= 4
                ? 0.8
                : selectedAlgorithmsLength <= 6
                    ? 0.7
                    : 0.6;
    return value.h / selectedAlgorithmsLength * (per - 0.15);
  }

  Duration get _speedDuration => state.speed.stepDuration*6;
  int get _size => state.size;

  SortingEnum get _getOperation => state.operationStatus;
  set _setOperation(SortingEnum value) => state = state.copyWith(operationStatus: value);

  // @override
  // void dispose() {
  //   _stopSorting();
  //   super.dispose();
  // }
  void _initializePositions() {
    final positions = <int, Offset>{};
    final itemWidth = calculateItemWidth(ScreenSize.context!, _size);
    for (int i = 0; i < state.list.length; i++) {
      positions[state.list[i].id] = Offset(i * (itemWidth + itemsPadding), 0);
    }
    state = state.copyWith(positions: positions);
  }

  @override
  void changeSpeed(PlaybackSpeed speed) {
    state = state.copyWith(speed: speed);
  }

  void changeSize(double size) {
    if (_getOperation == SortingEnum.played) return;
    final newSize = _minSize + (_maxSize - _minSize) * size;
    state = state.copyWith(size: newSize.toInt());
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
    );
    _initializePositions();
    _resetAllColors();
  }

  Future<void> _stopSorting() async {
    _resetItemColors();
    state = state.copyWith(
      operationStatus: SortingEnum.stopped,
    );
  }

  Future<void> _playSorting(BuildContext context) async {
    _setOperation = SortingEnum.played;
    await _startSelectedSorting();
    // if (context.mounted) _setOperation = SortingEnum.none;
  }

  @override
  Future<void> togglePlay(BuildContext context) async {
    if (state.isAtLastStep) {
      await reset();

      if (context.mounted) _playSorting(context);

      return;
    }

    final isPlaying = state.isPlaying;
    state = state.copyWith(operationStatus: isPlaying ? SortingEnum.stopped : SortingEnum.played);
    isPlaying ? _stopSorting() : _playSorting(context);
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
    );
    _initializePositions();
    _resetAllColors();
  }

  @override
  void stepForward() {
    if (state.isPlaying) return;

    final next = state.currentStepIndex + 1;
    if (next >= state.sortedSteps.length) return;

    _buildSort(stepIndex: next, makeOnlyOneStep: true);
  }

  @override
  void stepBackward() {
    if (state.isPlaying) return;
    final prev = state.currentStepIndex - 1;
    if (prev < 0) return;

    _buildSort(stepIndex: prev, makeOnlyOneStep: true);
  }

  Future<void> _resetAllColors() async {
    final list = List<SortableItem>.from(state.list);
    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(sortedStatus: SortingStatus.none);
      state = state.copyWith(list: list);
    }
  }

  Future<void> _greenSortedItemsAsDone() async {
    final list = List<SortableItem>.from(state.list);
    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(sortedStatus: SortingStatus.allSorted);
      state = state.copyWith(list: list);
      await Future.delayed(state.speed.stepDuration);
    }
  }

  Future<void> _startSelectedSorting() async {
    try {
      await _buildSort();
    } catch (e) {
      /// TODO: create cancel variable and cancel it when dispose
      debugPrint("something wrong with sorting: $e");
    }
  }

  bool _isPlayingFun = false;
  Future<void> _buildSort({int stepIndex = -1, bool makeOnlyOneStep = false}) async {
    if (_isPlayingFun) return;
    _isPlayingFun = true;

    final list = List<SortableItem>.from(state.list);
    final values = list.map((e) => e.value).toList();

    final sortedSteps = state.sortedSteps.isEmpty ? null : state.sortedSteps;
    final currentStepIndex = stepIndex == -1 ? state.currentStepIndex : stepIndex;

    final steps = sortedSteps ?? buildSorting(values).steps;

    if (!makeOnlyOneStep) {
      state = state.copyWith(
        totalPlaySteps: steps.length,
        currentStepIndex: currentStepIndex,
        sortedSteps: steps,
        currentStep: sortedSteps == null || currentStepIndex <= 0 ? SortingStep.noneStep() : sortedSteps[currentStepIndex],
      );
    }
    bool didSpecificStep = false;
    final step1 = stepIndex == -1 ? null : steps[stepIndex].index1;
    final step2 = stepIndex == -1 ? null : steps[stepIndex].index2;

    for (int i = currentStepIndex; i < steps.length; i++) {
      final prevStep = steps[i > 0 ? i - 1 : i];
      final step = steps[i];

      state = state.copyWith(
        currentStepIndex: i,
        currentStep: step,
      );

      if (_getOperation != SortingEnum.played && !makeOnlyOneStep) {
        _isPlayingFun = false;
        return;
      }

      if (didSpecificStep && (step1 != step.index1 || step2 != step.index2)) {
        _isPlayingFun = false;
        return;
      }
      if (prevStep.index1 != step.index1) {
        list[prevStep.index1] = list[prevStep.index1].copyWith(sortedStatus: SortingStatus.none);
        state = state.copyWith(list: list);
      }
      if (prevStep.index2 != step.index2) {
        list[prevStep.index2] = list[prevStep.index2].copyWith(sortedStatus: SortingStatus.none);
        state = state.copyWith(list: list);
      }
      switch (step.action) {
        case SortingStatus.compared:
          list[step.index1] = list[step.index1].copyWith(sortedStatus: SortingStatus.compared);
          list[step.index2] = list[step.index2].copyWith(sortedStatus: SortingStatus.compared);
          state = state.copyWith(list: list);
          await Future.delayed(_speedDuration);

        case SortingStatus.swapping:
          list[step.index1] = list[step.index1].copyWith(sortedStatus: SortingStatus.swapping);
          list[step.index2] = list[step.index2].copyWith(sortedStatus: SortingStatus.swapping);
          state = state.copyWith(list: list);
          await Future.delayed(_speedDuration);

          list.swap(step.index1, step.index2);
          final positions = Map<int, Offset>.from(state.positions);
          final tempPosition = positions[list[step.index1].id]!;
          positions[list[step.index1].id] = positions[list[step.index2].id]!;
          positions[list[step.index2].id] = tempPosition;
          state = state.copyWith(list: list, positions: positions);

        case SortingStatus.allSorted:
        case SortingStatus.none:
          list[step.index1] = list[step.index1].copyWith(sortedStatus: SortingStatus.none);
          list[step.index2] = list[step.index2].copyWith(sortedStatus: SortingStatus.none);
          state = state.copyWith(list: list);
      }

      await Future.delayed(_speedDuration);

      if (makeOnlyOneStep) didSpecificStep = true;
    }

    state = state.copyWith(currentStep: SortingStep.noneStep());
    await _greenSortedItemsAsDone();
    _isPlayingFun = false;
  }

  SortingResult buildSorting(List<int> values);
}
