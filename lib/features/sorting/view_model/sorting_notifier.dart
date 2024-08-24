import 'package:algorithm_visualizer/core/helpers/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

part 'sorting_state.dart';

class SortableItem {
  final int id;
  final int value;

  SortableItem(this.id, this.value);
}

class SortingNotifier extends StateNotifier<SortingNotifierState> {
  SortingNotifier()
      : super(SortingNotifierState(
          list: List.generate(_listSize, (index) => SortableItem(index, index + 1))..shuffle(),
        )) {
    _initializePositions();
  }

  static const int _listSize = 50;
  static double maxListItemHeight = 250.h;
  static double itemsPadding = 1.w;
  static const Duration swipeDuration = Duration(milliseconds: 5);

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
    return Colors.indigo.withOpacity(step);
  }

  void _initializePositions() {
    final positions = <int, Offset>{};
    final itemWidth = calculateItemWidth(ScreenSize.context!);

    for (int i = 0; i < state.list.length; i++) {
      positions[state.list[i].id] = Offset(i * (itemWidth + itemsPadding), 0);
    }
    state = state.copyWith(positions: positions);
  }

  Future<void> bubbleSort() async {
    final list = List<SortableItem>.from(state.list);
    for (int i = 0; i < list.length - 1; i++) {
      for (int j = 0; j < list.length - i - 1; j++) {
        if (list[j].value > list[j + 1].value) {
          // Swap items in the list
          final temp = list[j];
          list[j] = list[j + 1];
          list[j + 1] = temp;

          // Update positions for swap
          final positions = Map<int, Offset>.from(state.positions);
          final tempPosition = positions[list[j].id]!;
          positions[list[j].id] = positions[list[j + 1].id]!;
          positions[list[j + 1].id] = tempPosition;

          // Update state
          state = state.copyWith(list: list, positions: positions);

          // Delay for the animation to complete
          await Future.delayed(swipeDuration);
        }
      }
    }
  }
}
