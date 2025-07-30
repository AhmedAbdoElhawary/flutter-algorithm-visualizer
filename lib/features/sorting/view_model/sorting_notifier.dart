import 'package:algorithm_visualizer/core/helpers/screen_size.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:async/async.dart';

part 'sorting_state.dart';

enum SortingAlgorithm {
  bubble,
  selection,
  insertion,
  // merge,
  // quick,
  // shell,
  // heap,
  // count,
  // radix,
  // bucket,
}

enum SortingEnum { played, stopped, none }

enum SortingStatus { unSorted, compared, swapped, sorted, none }

/// a unique [id] for each item, but [value] can be repeated
class SortableItem {
  final int id;
  final int value;
  final SortingStatus sortedStatus;
  SortableItem({
    required this.id,
    required this.value,
    this.sortedStatus = SortingStatus.unSorted,
  });

  SortableItem copyWith({int? id, int? value, SortingStatus? sortedStatus}) {
    return SortableItem(
      id: id ?? this.id,
      value: value ?? this.value,
      sortedStatus: sortedStatus ?? this.sortedStatus,
    );
  }
}

class SortingNotifier extends StateNotifier<SortingNotifierState> {
  SortingNotifier()
      : super(SortingNotifierState(
            list: generateList(_defaultSize), selectedAlgorithms: [SortingAlgorithm.bubble])) {
    _initializePositions();
  }

  static const List<SortingAlgorithm> sortingAlgorithms = [
    SortingAlgorithm.bubble,
    SortingAlgorithm.selection,
    SortingAlgorithm.insertion,
    // SortingAlgorithm.merge,
    // SortingAlgorithm.quick,
    // SortingAlgorithm.shell,
    // SortingAlgorithm.heap,
    // SortingAlgorithm.count,
    // SortingAlgorithm.radix,
    // SortingAlgorithm.bucket
  ];
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

  SortingEnum _operation = SortingEnum.none;
  CancelableOperation<void>? _cancelableSort;

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

  Duration get _speedDuration => state.swipeDuration;
  int get _size => state.size;
  void selectAlgorithm(int index) {
    final target = sortingAlgorithms[index];
    final selected = [...state.selectedAlgorithms];
    final targetIndex = selected.indexOf(target);

    /// TODO: right now only single selected algorithm allowed
    selected.clear();

    if (targetIndex != -1) {
      selected.removeAt(targetIndex);
    } else {
      selected.add(target);
    }
    state = state.copyWith(selectedAlgorithms: selected);
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
    double duration = _size * p * (p*20);

    state = state.copyWith(swipeDuration: Duration(milliseconds: duration.toInt()));
  }

  void changeSize(double size) {
    final newSize = _minSize + (_maxSize - _minSize) * size;
    state = state.copyWith(size: newSize.toInt());
    generateAgain();
  }

  void stopSorting() {
    _cancelableSort?.cancel();
    _operation = SortingEnum.stopped;
  }

  void playSorting() {
    if (_operation == SortingEnum.played) return;
    _operation = SortingEnum.played;

    _startSelectedSorting();
  }

  void generateAgain() {
    _operation = SortingEnum.none;

    i = 0;
    j = 0;

    state = state.copyWith(list: generateList(_size), selectedAlgorithms: state.selectedAlgorithms);
    _initializePositions();
  }

  Future<void> _startSelectedSorting() async {
    if (state.selectedAlgorithms.isEmpty) return;

    switch (state.selectedAlgorithms.first) {
      case SortingAlgorithm.bubble:
        _cancelableSort = CancelableOperation.fromFuture(_bubbleSort());
        break;
      case SortingAlgorithm.selection:
        _cancelableSort = CancelableOperation.fromFuture(_selectionSort());
        break;
      case SortingAlgorithm.insertion:
        _cancelableSort = CancelableOperation.fromFuture(_insertionSort());
        break;
      // case SortingAlgorithm.merge:
      //   _cancelableSort = CancelableOperation.fromFuture(_mergeSort());
      //   break;
      // case SortingAlgorithm.quick:
      //   _cancelableSort = CancelableOperation.fromFuture(_quickSort());
      //   break;
      // case SortingAlgorithm.shell:
      //   _cancelableSort = CancelableOperation.fromFuture(_shellSort());
      //   break;
      // case SortingAlgorithm.heap:
      //   _cancelableSort = CancelableOperation.fromFuture(_heapSort());
      //   break;
      // case SortingAlgorithm.count:
      //   _cancelableSort = CancelableOperation.fromFuture(_countingSort());
      //   break;
      // case SortingAlgorithm.radix:
      //   _cancelableSort = CancelableOperation.fromFuture(_radixSort());
      //   break;
      // case SortingAlgorithm.bucket:
      //   _cancelableSort = CancelableOperation.fromFuture(_bucketSort());
      //   break;
    }
    try {
      await _cancelableSort?.value;
    } catch (e) {
      debugPrint("something wrong with bubbleSort: $e");
    }
  }

  Future<void> _greenSortedItemsAsDone() async {
    final list = List<SortableItem>.from(state.list);

    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(sortedStatus: SortingStatus.sorted);
      state = state.copyWith(list: list);
      await Future.delayed(state.swipeDuration);
    }
  }

  Future<void> _bubbleSort() async {
    final list = List<SortableItem>.from(state.list);

    for (i = 0; i < list.length - 1; i++) {
      if (_operation != SortingEnum.played) return;

      bool isSorted = true;

      for (j = 0; j < list.length - i - 1; j++) {
        if (_operation != SortingEnum.played) return;

        list[j] = list[j].copyWith(sortedStatus: SortingStatus.compared);
        list[j + 1] = list[j + 1].copyWith(sortedStatus: SortingStatus.compared);
        state = state.copyWith(list: list);

        if (_operation != SortingEnum.played) return;
        await Future.delayed(_speedDuration);
        if (_operation != SortingEnum.played) return;
        await Future.delayed(_speedDuration);

        if (list[j].value > list[j + 1].value) {
          list[j] = list[j].copyWith(sortedStatus: SortingStatus.swapped);
          list[j + 1] = list[j + 1].copyWith(sortedStatus: SortingStatus.swapped);
          state = state.copyWith(list: list);
          if (_operation != SortingEnum.played) return;

          await Future.delayed(_speedDuration);

          isSorted = false;
          list.swap(j, j + 1);

          final positions = Map<int, Offset>.from(state.positions);
          final tempPosition = positions[list[j].id]!;
          positions[list[j].id] = positions[list[j + 1].id]!;
          positions[list[j + 1].id] = tempPosition;

          state = state.copyWith(list: list, positions: positions);
          await Future.delayed(_speedDuration);
          if (_operation != SortingEnum.played) return;

          list[j] = list[j].copyWith(sortedStatus: SortingStatus.unSorted);
          list[j + 1] = list[j + 1].copyWith(sortedStatus: SortingStatus.unSorted);
          state = state.copyWith(list: list);

          await Future.delayed(_speedDuration);

          if (_operation != SortingEnum.played) return;
        } else {
          list[j] = list[j].copyWith(sortedStatus: SortingStatus.unSorted);
          list[j + 1] = list[j + 1].copyWith(sortedStatus: SortingStatus.unSorted);
          state = state.copyWith(list: list);
        }
      }

      if (isSorted) {
        await _greenSortedItemsAsDone();
        return;
      }
    }
    await _greenSortedItemsAsDone();
  }

  Future<void> _selectionSort() async {
    final list = List<SortableItem>.from(state.list);

    for (int i = 0; i < list.length - 1; i++) {
      if (_operation != SortingEnum.played) return;

      int minIndex = i;

      for (int j = i + 1; j < list.length; j++) {
        if (_operation != SortingEnum.played) return;

        list[minIndex] = list[minIndex].copyWith(sortedStatus: SortingStatus.compared);
        list[j] = list[j].copyWith(sortedStatus: SortingStatus.compared);
        state = state.copyWith(list: list);
        await Future.delayed(_speedDuration);

        if (list[j].value < list[minIndex].value) minIndex = j;

        list[j] = list[j].copyWith(sortedStatus: SortingStatus.unSorted);
        list[minIndex] = list[minIndex].copyWith(sortedStatus: SortingStatus.unSorted);
        state = state.copyWith(list: list);
      }

      if (minIndex != i) {
        list[minIndex] = list[minIndex].copyWith(sortedStatus: SortingStatus.swapped);
        list[i] = list[i].copyWith(sortedStatus: SortingStatus.swapped);
        state = state.copyWith(list: list);
        await Future.delayed(_speedDuration);

        list.swap(i, minIndex);

        final positions = Map<int, Offset>.from(state.positions);
        final temp = positions[list[i].id]!;
        positions[list[i].id] = positions[list[minIndex].id]!;
        positions[list[minIndex].id] = temp;

        state = state.copyWith(list: list, positions: positions);
        await Future.delayed(_speedDuration);

        list[i] = list[i].copyWith(sortedStatus: SortingStatus.unSorted);
        list[minIndex] = list[minIndex].copyWith(sortedStatus: SortingStatus.unSorted);
        state = state.copyWith(list: list);
      }
    }

    await _greenSortedItemsAsDone();
  }

  Future<void> _insertionSort() async {
    final list = List<SortableItem>.from(state.list);

    for (int i = 1; i < list.length; i++) {
      if (_operation != SortingEnum.played) return;

      SortableItem keyItem = list[i];
      int j = i - 1;

      while (j >= 0 && list[j].value > keyItem.value) {
        if (_operation != SortingEnum.played) return;

        list[j] = list[j].copyWith(sortedStatus: SortingStatus.compared);
        list[j + 1] = list[j + 1].copyWith(sortedStatus: SortingStatus.compared);
        state = state.copyWith(list: list);
        await Future.delayed(_speedDuration);

        list.swap(j, j + 1);

        final positions = Map<int, Offset>.from(state.positions);
        final temp = positions[list[j].id]!;
        positions[list[j].id] = positions[list[j + 1].id]!;
        positions[list[j + 1].id] = temp;

        state = state.copyWith(list: list, positions: positions);
        await Future.delayed(_speedDuration);

        list[j] = list[j].copyWith(sortedStatus: SortingStatus.unSorted);
        list[j + 1] = list[j + 1].copyWith(sortedStatus: SortingStatus.unSorted);
        state = state.copyWith(list: list);
        j--;
      }
    }

    await _greenSortedItemsAsDone();
  }
}
