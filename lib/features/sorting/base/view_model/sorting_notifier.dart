import 'package:algorithm_visualizer/core/helpers/o_notation.dart';
import 'package:algorithm_visualizer/core/helpers/screen_size.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:async/async.dart';

part 'sorting_state.dart';
part '../helper/sorting_enums.dart';
part '../helper/sortable_item.dart';

abstract class SortingNotifier extends StateNotifier<SortingNotifierState> {
  SortingNotifier() : super(SortingNotifierState(list: _generateList(_defaultSize))) {
    _initializePositions();
  }
  AlgorithmComplexity get algoComplexity;
  String get description;

  static const ThemeEnum swappingColor = ThemeEnum.redColor;
  static const ThemeEnum comparedColor = ThemeEnum.lightBlueColor;
  static const ThemeEnum itemColor = ThemeEnum.columnColor;
  static const ThemeEnum backgroundForSortingColor = ThemeEnum.backgroundForSortingColor;
  static const ThemeEnum doneSortingColor = ThemeEnum.greenColor;

  static const int _defaultSize = 9;
  static const int _maxSize = 15;
  static const int _minSize = 5;
  static double itemsPadding = 5.w;
  static double horizontalInsidePadding = (30 + bottomInsidePadding * 2).r;
  static const double bottomInsidePadding = 20;
  static double horizontalOutSidePadding = 32.r;

  static const Duration _defaultSpeedDuration = Duration(milliseconds: 300);

  CancelableOperation<void>? _cancelableSort;
  CancelableOperation<void>? _cancelableItemsDone;

  static List<SortableItem> _generateList(int size) {
    return List.generate(size, (index) => SortableItem(id: index, value: index + 1))..shuffle();
  }

  static double calculateItemWidth(BuildContext context, int size) {
    final screenWidth = MediaQuery.of(context).size.width - horizontalInsidePadding;
    final availableWidth = screenWidth - (itemsPadding * (size - 1));

    final width = availableWidth / size > 0 ? availableWidth / size : 1.0;
    return width;
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
    final perc = selectedAlgorithmsLength == 1
        ? 0.8
        : selectedAlgorithmsLength <= 2
            ? 0.9
            : selectedAlgorithmsLength <= 4
                ? 0.8
                : selectedAlgorithmsLength <= 6
                    ? 0.7
                    : 0.6;
    return value.h / selectedAlgorithmsLength * perc;
  }

  Duration get speedDuration => state.swipeDuration;
  int get _size => state.size;

  SortingEnum get _getOperation => state.operationStatus;

  set _setOperation(SortingEnum value) {
    state = state.copyWith(operationStatus: value);
  }

  void _initializePositions() {
    final positions = <int, Offset>{};
    final itemWidth = calculateItemWidth(ScreenSize.context!, _size);

    for (int i = 0; i < state.list.length; i++) {
      positions[state.list[i].id] = Offset(i * (itemWidth + itemsPadding), 0);
    }
    state = state.copyWith(positions: positions);
  }

  void changeSpeed(double percent) {
    final p = 1 - (percent);
    double duration = _size * p * (p * 20);

    state = state.copyWith(swipeDuration: Duration(milliseconds: duration.toInt()));
  }

  void changeSize(double size) {
    if (_getOperation == SortingEnum.played) return;

    final newSize = _minSize + (_maxSize - _minSize) * size;
    state = state.copyWith(size: newSize.toInt());
    generateAgain();
  }

  Future<void> cancelSorting() async {
    await _cancelableSort?.cancel();
    await _cancelableItemsDone?.cancel();
  }

  Future<void> stopSorting() async {
    await _cancelableSort?.cancel();
    await _cancelableItemsDone?.cancel();
    if (_getOperation == SortingEnum.played) _setOperation = SortingEnum.stopped;
  }

  Future<void> playSorting(BuildContext context) async {
    if (_getOperation == SortingEnum.played) return;
    _setOperation = SortingEnum.played;

    await _startSelectedSorting();

// to avoid error of mounted when popup while the sorting algorithm still running
    if (context.mounted) _setOperation = SortingEnum.none;
  }

  Future<void> generateAgain() async {
    await _cancelableSort?.cancel();
    await _cancelableItemsDone?.cancel();
    _setOperation = SortingEnum.none;

    state = state.copyWith(list: _generateList(_size));
    _initializePositions();
  }

  Future<void> _greenSortedItemsAsDone() async {
    _cancelableItemsDone = CancelableOperation.fromFuture(_itemsDone());

    try {
      await _cancelableItemsDone?.value;
    } catch (e) {
      debugPrint("something wrong with cancel mark done for items: $e");
    }
  }

  Future<void> _itemsDone() async {
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

  Future<void> _buildSort() async {
    final list = List<SortableItem>.from(state.list);
    final values = list.map((e) => e.value).toList();

    final steps = buildSorting(values).steps;

    for (final step in steps) {
      if (_getOperation != SortingEnum.played) return;

      switch (step.action) {
        case SortingStatus.compared:
          list[step.index1] = list[step.index1].copyWith(sortedStatus: SortingStatus.compared);
          list[step.index2] = list[step.index2].copyWith(sortedStatus: SortingStatus.compared);
          state = state.copyWith(list: list);

          await Future.delayed(speedDuration);

          break;

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
          break;

        case SortingStatus.swapped:
        case SortingStatus.unSorted:
          list[step.index1] = list[step.index1].copyWith(sortedStatus: SortingStatus.unSorted);
          list[step.index2] = list[step.index2].copyWith(sortedStatus: SortingStatus.unSorted);
          state = state.copyWith(list: list);
          break;

        /// i don't want to make it green while sorting and mark all of them at once as green at the end
        case SortingStatus.sorted:
        case SortingStatus.none:
          list[step.index1] = list[step.index1].copyWith(sortedStatus: SortingStatus.none);
          state = state.copyWith(list: list);
          break;
      }

      await Future.delayed(speedDuration);
    }

    await _greenSortedItemsAsDone();
  }

  SortingResult buildSorting(List<int> values);
}
