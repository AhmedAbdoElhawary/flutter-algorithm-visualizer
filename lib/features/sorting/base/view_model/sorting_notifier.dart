import 'package:algorithm_visualizer/core/helpers/screen_size.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/features/base/view_model/base_page_view_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:async/async.dart';

part 'sorting_state.dart';
part '../helper/sorting_enums.dart';
part '../helper/sortable_item.dart';

enum SpeedStatus { normal, average, fast }

abstract class SortingNotifier extends StateNotifier<SortingNotifierState> implements AlgorithmNotifier {
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

  static const Duration _defaultSpeedDuration = Duration(milliseconds: 300);

  CancelableOperation<void>? _cancelableSort;

  bool get isPlaying => state.isPlaying;
  bool get isAtFirstStep => state.isAtFirstStep;
  bool get isAtLastStep => state.isAtLastStep;
  bool get isInStepMode => state.isInStepMode;

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

  Duration get speedDuration => state.swipeDuration;
  int get _size => state.size;

  SortingEnum get _getOperation => state.operationStatus;
  set _setOperation(SortingEnum value) => state = state.copyWith(operationStatus: value);

  void _initializePositions() {
    final positions = <int, Offset>{};
    final itemWidth = calculateItemWidth(ScreenSize.context!, _size);
    for (int i = 0; i < state.list.length; i++) {
      positions[state.list[i].id] = Offset(i * (itemWidth + itemsPadding), 0);
    }
    state = state.copyWith(positions: positions);
  }

  void changeSpeed(SpeedStatus speedStatus) {
    final defaultSpeed = _defaultSpeedDuration.inMilliseconds.toDouble();
    final duration = speedStatus == SpeedStatus.normal
        ? defaultSpeed
        : speedStatus == SpeedStatus.average
            ? defaultSpeed / 1.5
            : defaultSpeed / 2;
    state = state.copyWith(swipeDuration: Duration(milliseconds: duration.toInt()));
  }

  void changeSize(double size) {
    if (_getOperation == SortingEnum.played) return;
    final newSize = _minSize + (_maxSize - _minSize) * size;
    state = state.copyWith(size: newSize.toInt());
    generateAgain();
  }

  void _resetItemColors() {
    final cleanList = state.list.map((item) => item.copyWith(sortedStatus: SortingStatus.none)).toList();
    state = state.copyWith(list: cleanList);
  }

  Future<void> cancelSorting() async {
    await _cancelableSort?.cancel();
    _cancelableSort = null;
    state = state.copyWith(
      list: _generateList(_size),
      operationStatus: SortingEnum.none,
      currentCodeLine: -1,
      totalPlaySteps: 0,
      stepSnapshots: [],
      positionSnapshots: [],
      codeLineSnapshots: [],
      sortedSteps: [],
      currentStepIndex: 0,
    );
    _initializePositions();
  }

  Future<void> stopSorting() async {
    if (!state.isPlaying) return;
    await _cancelableSort?.cancel();
    _cancelableSort = null;
    _resetItemColors();
    state = state.copyWith(
      operationStatus: SortingEnum.stopped,
      // currentCodeLine: -1,
      stepSnapshots: [],
      positionSnapshots: [],
      codeLineSnapshots: [],
      // currentStepIndex: -1,
    );
  }

  Future<void> playSorting(BuildContext context) async {
    if (_getOperation == SortingEnum.played) return;
    _setOperation = SortingEnum.played;
    await _startSelectedSorting();
    if (context.mounted) _setOperation = SortingEnum.none;
  }

  Future<void> generateAgain() async {
    await _cancelableSort?.cancel();
    state = state.copyWith(
      list: _generateList(_size),
      operationStatus: SortingEnum.none,
      currentCodeLine: -1,
      totalPlaySteps: 0,
      stepSnapshots: [],
      positionSnapshots: [],
      codeLineSnapshots: [],
      sortedSteps: [],
      currentStepIndex: 0,
    );
    _initializePositions();
  }

  void stepForward() {
    if (state.isPlaying) return;
    // if (!state.isInStepMode) _precomputeSnapshots();

    final next = state.currentStepIndex + 1;
    if (next >= state.sortedSteps.length) return;

    _buildSort(stepIndex: next, makeOnlyOneStep: true);
  }

  void stepBackward() {
    if (state.isPlaying) return;
    // if (!state.isInStepMode) return;

    final prev = state.currentStepIndex - 1;
    if (prev < 0) return;

    _buildSort(stepIndex: prev, makeOnlyOneStep: true);
  }

  Future<void> _greenSortedItemsAsDone() async {
    final list = List<SortableItem>.from(state.list);
    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(sortedStatus: SortingStatus.sorted);
      state = state.copyWith(list: list);
      await Future.delayed(state.swipeDuration);
    }
  }

  Future<void> _startSelectedSorting() async {
    _cancelableSort = CancelableOperation.fromFuture(_buildSort());
    try {
      await _cancelableSort?.value;
    } catch (e) {
      debugPrint("something wrong with sorting: $e");
    }
  }

  Future<void> _buildSort({int stepIndex = -1, bool makeOnlyOneStep = false}) async {
    final list = List<SortableItem>.from(state.list);
    final values = list.map((e) => e.value).toList();

    final sortedSteps = state.sortedSteps.isEmpty ? null : state.sortedSteps;
    final currentStepIndex = stepIndex == -1 ? state.currentStepIndex : stepIndex;

    final steps = sortedSteps ?? buildSorting(values).steps;

    state = state.copyWith(
      totalPlaySteps: steps.length,
      currentStepIndex: currentStepIndex,
      sortedSteps: steps,
      currentCodeLine:
          sortedSteps == null || currentStepIndex <= 0 ? -1 : codeLineForStep(sortedSteps[currentStepIndex]),
    );

    bool didSpecificStep = false;
    for (int i = currentStepIndex; i < steps.length; i++) {

      final step = steps[i];

      state = state.copyWith(
        currentStepIndex: i,
        currentCodeLine: codeLineForStep(step),
      );

      if (_getOperation != SortingEnum.played && !makeOnlyOneStep) return;

      if (didSpecificStep) return;

      switch (step.action) {
        case SortingStatus.compared:
          list[step.index1] = list[step.index1].copyWith(sortedStatus: SortingStatus.compared);
          list[step.index2] = list[step.index2].copyWith(sortedStatus: SortingStatus.compared);
          state = state.copyWith(list: list);
          await Future.delayed(speedDuration);

        case SortingStatus.swapping:
          list[step.index1] = list[step.index1].copyWith(sortedStatus: SortingStatus.swapping);
          list[step.index2] = list[step.index2].copyWith(sortedStatus: SortingStatus.swapping);
          state = state.copyWith(list: list);
          await Future.delayed(speedDuration);

          list.swap(step.index1, step.index2);
          final positions = Map<int, Offset>.from(state.positions);
          final tempPosition = positions[list[step.index1].id]!;
          positions[list[step.index1].id] = positions[list[step.index2].id]!;
          positions[list[step.index2].id] = tempPosition;
          state = state.copyWith(list: list, positions: positions);

        case SortingStatus.swapped:
        case SortingStatus.unSorted:
          list[step.index1] = list[step.index1].copyWith(sortedStatus: SortingStatus.unSorted);
          list[step.index2] = list[step.index2].copyWith(sortedStatus: SortingStatus.unSorted);
          state = state.copyWith(list: list);

        case SortingStatus.sorted:
        case SortingStatus.none:
          list[step.index1] = list[step.index1].copyWith(sortedStatus: SortingStatus.none);
          state = state.copyWith(list: list);
      }

      await Future.delayed(speedDuration);

      if (makeOnlyOneStep) didSpecificStep = true;
    }

    state = state.copyWith(currentCodeLine: -1);
    await _greenSortedItemsAsDone();
  }

  SortingResult buildSorting(List<int> values);
}
