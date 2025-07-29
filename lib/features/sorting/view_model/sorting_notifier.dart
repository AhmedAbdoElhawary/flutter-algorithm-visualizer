import 'package:algorithm_visualizer/core/helpers/screen_size.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:async/async.dart';

part 'sorting_state.dart';

enum SortingAlgorithm { bubble, selection, insertion, merge, quick }

enum SortingEnum { played, stopped, none }

//SortingAlgorithm
class ComparableItems {
  final SortableItem first;
  final SortableItem second;

  ComparableItems({required this.first, required this.second});
}

class SortableItem {
  final int id;
  final int value;

  SortableItem(this.id, this.value);
}

class SortingNotifier extends StateNotifier<SortingNotifierState> {
  SortingNotifier() : super(SortingNotifierState(list: generateList())) {
    _initializePositions();
  }

  static const List<SortingAlgorithm> sortingAlgorithms = [
    SortingAlgorithm.bubble,
    SortingAlgorithm.selection,
    SortingAlgorithm.insertion,
    SortingAlgorithm.merge,
    SortingAlgorithm.quick,
  ];
  static const int _listSize = 30;
  static double maxListItemHeight = 250.h;
  static double itemsPadding = 1.w;
  static const ThemeEnum comparedColor = ThemeEnum.comparedColor;
  static const ThemeEnum itemColor = ThemeEnum.blueColor;
  static const Duration swipeDuration = Duration(milliseconds: 50);
  static const Duration stopForThinkingDuration = Duration(milliseconds: 100);
  SortingEnum _operation = SortingEnum.none;
  CancelableOperation<void>? _cancelableSort;

  int i = 0;
  int j = 0;

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

  // static Color getColor(int itemIndex) {
  //   double step = (itemIndex * 2) / 100;
  //   final value = step + 0.1 > 1 ? 1.0 : step + 0.1;
  //
  //   return Colors.indigo.withValues(alpha: value);
  // }

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
    final itemWidth = calculateItemWidth(ScreenSize.context!);

    for (int i = 0; i < state.list.length; i++) {
      positions[state.list[i].id] = Offset(i * (itemWidth + itemsPadding), 0);
    }
    state = state.copyWith(positions: positions);
  }

  void stopSorting() {
    _cancelableSort?.cancel();
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

  Future<void> bubbleSort() async {
    _cancelableSort = CancelableOperation.fromFuture(_bubbleSort());
    try {
      await _cancelableSort?.value;
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
        await Future.delayed(stopForThinkingDuration);

        state = state.copyWith(comparableTwoItems: ComparableItems(first: list[j], second: list[j + 1]));
        await Future.delayed(stopForThinkingDuration);

        if (list[j].value > list[j + 1].value) {
          list.swap(j, j + 1);

          final positions = Map<int, Offset>.from(state.positions);
          final tempPosition = positions[list[j].id]!;
          positions[list[j].id] = positions[list[j + 1].id]!;
          positions[list[j + 1].id] = tempPosition;

          state = state.copyWith(list: list, positions: positions);
          await Future.delayed(swipeDuration);
        }
      }
    }
  }
}
