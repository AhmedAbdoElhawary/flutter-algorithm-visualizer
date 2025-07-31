import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class SelectionSortNotifier extends SortingNotifier {
  @override
  Future<void> buildSort() async {
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

}
