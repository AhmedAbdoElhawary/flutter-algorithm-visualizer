import 'package:algorithm_visualizer/core/helpers/screen_size.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
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
    if (operation == SortingEnum.played) return;

    final newSize = _minSize + (_maxSize - _minSize) * size;
    state = state.copyWith(size: newSize.toInt());
    generateAgain();
  }

  void stopSorting() {
    cancelableSort?.cancel();
    operation = SortingEnum.stopped;
  }

  Future<void> playSorting() async {
    if (operation == SortingEnum.played) return;
    operation = SortingEnum.played;

    await startSelectedSorting();

    operation = SortingEnum.none;
  }

  Future<void> generateAgain() async {
    await cancelableSort?.cancel();
    operation = SortingEnum.none;

    i = 0;
    j = 0;

    state = state.copyWith(list: generateList(_size));
    _initializePositions();
  }

  Future<void> greenSortedItemsAsDone() async {
    final list = List<SortableItem>.from(state.list);

    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(sortedStatus: SortingStatus.sorted);
      state = state.copyWith(list: list);
      await Future.delayed(state.swipeDuration);
    }
  }

  Future<void> startSelectedSorting() async {
    cancelableSort = CancelableOperation.fromFuture(buildSort());

    try {
      await cancelableSort?.value;
    } catch (e) {
      debugPrint("something wrong with bubbleSort: $e");
    }
  }

  Future<void> buildSort();
}
