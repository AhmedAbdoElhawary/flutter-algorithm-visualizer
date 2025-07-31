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
  SortingNotifier() : super(SortingNotifierState(list: generateList(_defaultSize))) {
    _initializePositions();
  }

  static double maxListItemHeight = 250.h;
  static double itemsPadding = 1.w;
  static const ThemeEnum swipedColor = ThemeEnum.redColor;
  static const ThemeEnum comparedColor = ThemeEnum.comparedColor;
  static const ThemeEnum itemColor = ThemeEnum.blueColor;
  static const ThemeEnum doneSortingColor = ThemeEnum.greenColor;

  static const int _defaultSize = 20;
  static const int _maxSize = 100;
  static const int _minSize = 10;

  static const Duration _defaultSpeedDuration = Duration(milliseconds: 300);
  // static const Duration _maxSpeedDuration = Duration(milliseconds: 3000);
  // static const Duration _minSpeedDuration = Duration(milliseconds: 20);

  SortingEnum operation = SortingEnum.none;
  CancelableOperation<void>? cancelableSort;

  int i = 0;
  int j = 0;

  static List<SortableItem> generateList(int size) {
    return List.generate(size, (index) => SortableItem(id: index, value: index + 1))..shuffle();
  }

  static double calculateItemWidth(BuildContext context, int size) {
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - (itemsPadding * (size - 1));

    // Ensure a positive width
    return availableWidth / size > 0 ? availableWidth / size : 1.0;
  }

  static double calculateItemHeight(int itemIndex, int size) {
    final value = (maxListItemHeight / size) * (itemIndex + 1);
    return value.h;
  }

  Duration get speedDuration => state.swipeDuration;
  int get _size => state.size;

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
    final newSize = _minSize + (_maxSize - _minSize) * size;
    state = state.copyWith(size: newSize.toInt());
    generateAgain();
  }

  void stopSorting() {
    cancelableSort?.cancel();
    operation = SortingEnum.stopped;
  }

  void playSorting() {
    if (operation == SortingEnum.played) return;
    operation = SortingEnum.played;

    startSelectedSorting();
  }

  void generateAgain() {
    operation = SortingEnum.none;

    i = 0;
    j = 0;

    state = state.copyWith(list: generateList(_size));
    _initializePositions();
  }

  Future<void> startSelectedSorting();

  Future<void> greenSortedItemsAsDone() async {
    final list = List<SortableItem>.from(state.list);

    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(sortedStatus: SortingStatus.sorted);
      state = state.copyWith(list: list);
      await Future.delayed(state.swipeDuration);
    }
  }

  Future<void> _selectionSort() async {
    final list = List<SortableItem>.from(state.list);

    for (int i = 0; i < list.length - 1; i++) {
      if (operation != SortingEnum.played) return;

      int minIndex = i;

      for (int j = i + 1; j < list.length; j++) {
        if (operation != SortingEnum.played) return;

        list[minIndex] = list[minIndex].copyWith(sortedStatus: SortingStatus.compared);
        list[j] = list[j].copyWith(sortedStatus: SortingStatus.compared);
        state = state.copyWith(list: list);
        await Future.delayed(speedDuration);

        if (list[j].value < list[minIndex].value) minIndex = j;

        list[j] = list[j].copyWith(sortedStatus: SortingStatus.unSorted);
        list[minIndex] = list[minIndex].copyWith(sortedStatus: SortingStatus.unSorted);
        state = state.copyWith(list: list);
      }

      if (minIndex != i) {
        list[minIndex] = list[minIndex].copyWith(sortedStatus: SortingStatus.swapped);
        list[i] = list[i].copyWith(sortedStatus: SortingStatus.swapped);
        state = state.copyWith(list: list);
        await Future.delayed(speedDuration);

        list.swap(i, minIndex);

        final positions = Map<int, Offset>.from(state.positions);
        final temp = positions[list[i].id]!;
        positions[list[i].id] = positions[list[minIndex].id]!;
        positions[list[minIndex].id] = temp;

        state = state.copyWith(list: list, positions: positions);
        await Future.delayed(speedDuration);

        list[i] = list[i].copyWith(sortedStatus: SortingStatus.unSorted);
        list[minIndex] = list[minIndex].copyWith(sortedStatus: SortingStatus.unSorted);
        state = state.copyWith(list: list);
      }
    }

    await greenSortedItemsAsDone();
  }

  Future<void> _insertionSort() async {
    final list = List<SortableItem>.from(state.list);

    for (int i = 1; i < list.length; i++) {
      if (operation != SortingEnum.played) return;

      SortableItem keyItem = list[i];
      int j = i - 1;

      while (j >= 0 && list[j].value > keyItem.value) {
        if (operation != SortingEnum.played) return;

        list[j] = list[j].copyWith(sortedStatus: SortingStatus.compared);
        list[j + 1] = list[j + 1].copyWith(sortedStatus: SortingStatus.compared);
        state = state.copyWith(list: list);
        await Future.delayed(speedDuration);

        list.swap(j, j + 1);

        final positions = Map<int, Offset>.from(state.positions);
        final temp = positions[list[j].id]!;
        positions[list[j].id] = positions[list[j + 1].id]!;
        positions[list[j + 1].id] = temp;

        state = state.copyWith(list: list, positions: positions);
        await Future.delayed(speedDuration);

        list[j] = list[j].copyWith(sortedStatus: SortingStatus.unSorted);
        list[j + 1] = list[j + 1].copyWith(sortedStatus: SortingStatus.unSorted);
        state = state.copyWith(list: list);
        j--;
      }
    }

    await greenSortedItemsAsDone();
  }
}
