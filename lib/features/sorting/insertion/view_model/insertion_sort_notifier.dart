import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class InsertionSortNotifier extends SortingNotifier {
  @override
  Future<void> buildSort() async {
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
