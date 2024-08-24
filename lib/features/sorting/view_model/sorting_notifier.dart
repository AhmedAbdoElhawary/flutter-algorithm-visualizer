import 'package:algorithm_visualizer/core/helpers/screen_size.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:async/async.dart';

part 'sorting_state.dart';

enum SortingEnum { played, stopped, none }

class SortableItem {
  final int id;
  final int value;

  SortableItem(this.id, this.value);
}

class SortingNotifier extends StateNotifier<SortingNotifierState> {
  SortingNotifier() : super(SortingNotifierState(list: generateList())) {
    _initializePositions();
  }

  static const int _listSize = 50;
  static double maxListItemHeight = 250.h;
  static double itemsPadding = 1.w;
  static const Duration swipeDuration = Duration(milliseconds: 5);
  SortingEnum _operation = SortingEnum.none;
  CancelableOperation<void>? _cancelableBubbleSort;

  static List<SortableItem> generateList() {
    return List.generate(_listSize, (index) => SortableItem(index, index + 1))..shuffle();
  }

  static double calculateItemWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - (itemsPadding * (_listSize - 1));

    // Ensure a positive width
    return availableWidth / _listSize > 0 ? availableWidth / _listSize : 1.0;
  }

  static double calculateItemHeight(int itemIndex) {
    final value = (maxListItemHeight / _listSize) * (itemIndex + 1);
    return value.h;
  }

  static Color getColor(int itemIndex) {
    double step = (itemIndex * 2) / 100;
    final value = step + 0.1 > 1 ? 1.0 : step + 0.1;

    return Colors.indigo.withOpacity(value);
  }

  void _initializePositions() {
    final positions = <int, Offset>{};
    final itemWidth = calculateItemWidth(ScreenSize.context!);

    for (int i = 0; i < state.list.length; i++) {
      positions[state.list[i].id] = Offset(i * (itemWidth + itemsPadding), 0);
    }
    state = state.copyWith(positions: positions);
  }

  void stopSorting() {
    _cancelableBubbleSort?.cancel();
    _operation = SortingEnum.stopped;
  }

  void playSorting() {
    if (_operation == SortingEnum.played) return;
    _operation = SortingEnum.played;

    bubbleSort();
  }

  void generateAgain() {
    _operation = SortingEnum.stopped;

    i = 0;
    j = 0;

    state = state.copyWith(list: generateList());
    _initializePositions();
  }

  int i = 0;
  int j = 0;

  Future<void> bubbleSort() async {
    _cancelableBubbleSort = CancelableOperation.fromFuture(_bubbleSort());
    try {
      await _cancelableBubbleSort?.value;
    } catch (e) {
      debugPrint("something wrong with bubbleSort: $e");
    }
  }

  Future<void> _bubbleSort() async {
    final list = List<SortableItem>.from(state.list);

    for (i = 0; i < list.length - 1; i++) {
      if (_operation != SortingEnum.played) return;

      for (j = 0; j < list.length - i - 1; j++) {
        if (_operation != SortingEnum.played) return;

        if (list[j].value > list[j + 1].value) {
          if (_operation != SortingEnum.played) return;
          list.swap(j, j + 1);

          final positions = Map<int, Offset>.from(state.positions);
          final tempPosition = positions[list[j].id]!;
          positions[list[j].id] = positions[list[j + 1].id]!;
          positions[list[j + 1].id] = tempPosition;

          state = state.copyWith(list: list, positions: positions);

          await Future.delayed(swipeDuration);
          if (_operation != SortingEnum.played) return;
        }
      }
    }
  }
}
