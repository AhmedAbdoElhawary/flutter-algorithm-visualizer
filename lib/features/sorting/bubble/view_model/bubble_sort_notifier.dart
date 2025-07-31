import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class BubbleSortNotifier extends SortingNotifier {
  @override
  Future<void> buildSort() async {
    final list = List<SortableItem>.from(state.list);
    final values = list.map((e) => e.value).toList();

    final steps = bubbleSortSteps(values);

    for (final step in steps) {
      if (operation != SortingEnum.played) return;

      switch (step.action) {
        case SortingStatus.compared:
          list[step.index1] = list[step.index1].copyWith(sortedStatus: SortingStatus.compared);
          list[step.index2] = list[step.index2].copyWith(sortedStatus: SortingStatus.compared);
          state = state.copyWith(list: list);

          await Future.delayed(speedDuration);

          break;

        case SortingStatus.swapped:
          list[step.index1] = list[step.index1].copyWith(sortedStatus: SortingStatus.swapped);
          list[step.index2] = list[step.index2].copyWith(sortedStatus: SortingStatus.swapped);
          state = state.copyWith(list: list);

          await Future.delayed(speedDuration);

          list.swap(step.index1, step.index2);

          final positions = Map<int, Offset>.from(state.positions);
          final tempPosition = positions[list[step.index1].id]!;
          positions[list[step.index1].id] = positions[list[step.index2].id]!;
          positions[list[step.index2].id] = tempPosition;

          state = state.copyWith(list: list, positions: positions);
          break;

        case SortingStatus.unSorted:
          list[step.index1] = list[step.index1].copyWith(sortedStatus: SortingStatus.unSorted);
          list[step.index2] = list[step.index2].copyWith(sortedStatus: SortingStatus.unSorted);
          state = state.copyWith(list: list);
          break;

        // i don't want to make it green while sorting and mark all of them at once as green at the end
        case SortingStatus.sorted:
        case SortingStatus.none:
          list[step.index1] = list[step.index1].copyWith(sortedStatus: SortingStatus.none);
          state = state.copyWith(list: list);
          break;
      }

      await Future.delayed(speedDuration);
    }

    await greenSortedItemsAsDone();
  }

  List<BubbleSortStep> bubbleSortSteps(List<int> values) {
    final steps = <BubbleSortStep>[];
    final arr = List<int>.from(values);

    for (int i = 0; i < arr.length - 1; i++) {
      bool isSorted = true;

      for (int j = 0; j < arr.length - i - 1; j++) {
        steps.add(BubbleSortStep(index1: j, index2: j + 1, action: SortingStatus.compared)); // external

        if (arr[j] > arr[j + 1]) {
          steps.add(BubbleSortStep(index1: j, index2: j + 1, action: SortingStatus.swapped)); // external
          final tmp = arr[j];
          arr[j] = arr[j + 1];
          arr[j + 1] = tmp;
          isSorted = false;
        }

        steps.add(BubbleSortStep(index1: j, index2: j + 1, action: SortingStatus.unSorted)); // external
      }

      steps.add(BubbleSortStep(
          index1: arr.length - i - 1, index2: arr.length - i - 1, action: SortingStatus.sorted)); // external

      if (isSorted) break;
    }

    return steps;
  }
}

class BubbleSortStep {
  final int index1;
  final int index2;
  final SortingStatus action;

  BubbleSortStep({
    required this.index1,
    required this.index2,
    required this.action,
  });
}
