import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class BubbleSortNotifier extends SortingNotifier {
  @override
  Future<void> startSelectedSorting() async {
    cancelableSort = CancelableOperation.fromFuture(_bubbleSort());

    try {
      await cancelableSort?.value;
    } catch (e) {
      debugPrint("something wrong with bubbleSort: $e");
    }
  }

  Future<void> _bubbleSort() async {
    final list = List<SortableItem>.from(state.list);

    for (i = 0; i < list.length - 1; i++) {
      if (operation != SortingEnum.played) return;

      bool isSorted = true;

      for (j = 0; j < list.length - i - 1; j++) {
        if (operation != SortingEnum.played) return;

        list[j] = list[j].copyWith(sortedStatus: SortingStatus.compared);
        list[j + 1] = list[j + 1].copyWith(sortedStatus: SortingStatus.compared);
        state = state.copyWith(list: list);

        if (operation != SortingEnum.played) return;
        await Future.delayed(speedDuration);
        if (operation != SortingEnum.played) return;
        await Future.delayed(speedDuration);

        if (list[j].value > list[j + 1].value) {
          list[j] = list[j].copyWith(sortedStatus: SortingStatus.swapped);
          list[j + 1] = list[j + 1].copyWith(sortedStatus: SortingStatus.swapped);
          state = state.copyWith(list: list);
          if (operation != SortingEnum.played) return;

          await Future.delayed(speedDuration);

          isSorted = false;
          list.swap(j, j + 1);

          final positions = Map<int, Offset>.from(state.positions);
          final tempPosition = positions[list[j].id]!;
          positions[list[j].id] = positions[list[j + 1].id]!;
          positions[list[j + 1].id] = tempPosition;

          state = state.copyWith(list: list, positions: positions);
          await Future.delayed(speedDuration);
          if (operation != SortingEnum.played) return;

          list[j] = list[j].copyWith(sortedStatus: SortingStatus.unSorted);
          list[j + 1] = list[j + 1].copyWith(sortedStatus: SortingStatus.unSorted);
          state = state.copyWith(list: list);

          await Future.delayed(speedDuration);

          if (operation != SortingEnum.played) return;
        } else {
          list[j] = list[j].copyWith(sortedStatus: SortingStatus.unSorted);
          list[j + 1] = list[j + 1].copyWith(sortedStatus: SortingStatus.unSorted);
          state = state.copyWith(list: list);
        }
      }

      if (isSorted) {
        await greenSortedItemsAsDone();
        return;
      }
    }
    await greenSortedItemsAsDone();
  }
}
