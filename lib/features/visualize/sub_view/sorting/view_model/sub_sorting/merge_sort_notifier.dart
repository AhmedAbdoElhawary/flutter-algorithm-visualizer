import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:collection/collection.dart';

class MergeSortNotifier extends SortingNotifier {
  @override
  SortingResult buildSorting(List<int> values) {
    final steps = <SortingStep>[];
    final arr = List<int>.from(values);

    if (arr.isEmpty) return SortingResult(sortedValues: [], steps: []);

    if (arr.length == 1) {
      return SortingResult(
        steps: [SortingStep(index1: 0, index2: 0, action: SortingStatus.sorted)],
        sortedValues: [arr[0]],
      );
    }

    void mergeTwoSortedLists(List<int> arr, int left, int mid, int right) {
      // imagine the list is split into two sorted lists
      // [left...mid] and [mid+1...right]
      int i = left;
      int j = mid + 1;

      while (i <= mid && j <= right) {
        steps.add(SortingStep(index1: i, index2: j, action: SortingStatus.compared));
        if (arr[i] <= arr[j]) {
          i++;
        } else {
          int index = j;
          while (index > i) {
            steps.add(SortingStep(index1: index, index2: index - 1, action: SortingStatus.swapping));
            arr.swap(index, index - 1);
            index--;
          }

          i++;
          mid++;
          j++;
        }
      }
    }

    void mergeSort(List<int> arr, int left, int right) {
      if (left >= right) return;

      final midIndex = (left + right) ~/ 2;

      mergeSort(arr, left, midIndex);
      mergeSort(arr, midIndex + 1, right);

      mergeTwoSortedLists(arr, left, midIndex, right);
    }

    mergeSort(arr, 0, arr.length - 1);

    return SortingResult(sortedValues: arr, steps: steps);
  }

  static final algorithmComplexity = AlgorithmComplexity(
    name: StringsManager.mergeSort,
    bestTimeComplexity: ONotationComplexity.nLogN,
    averageTimeComplexity: ONotationComplexity.nLogN,
    worstTimeComplexity: ONotationComplexity.nLogN,
    spaceComplexity: ONotationComplexity.n,
    stable: true,
  );

  @override
  AlgorithmComplexity get algoComplexity => algorithmComplexity;

  @override
  String get algorithmDescription => StringsManager.mergeSortDescription;
  @override
  List<String> get codeSnippet => const [
        'void main() {', // 0
        '  List<int> arr = [64, 34, 25, 12, 22, 11, 90];', // 1
        '  mergeSort(arr, 0, arr.length - 1);', // 2
        '}', // 3
        'void mergeSort(List<int> arr, int left, int right) {', // 4
        '  if (left < right) {', // 5
        '    int mid = (left + right) >> 1;', // 6
        '    mergeSort(arr, left, mid);', // 7
        '    mergeSort(arr, mid + 1, right);', // 8
        '    mergeInPlace(arr, left, mid, right);', // 9
        '  }', // 10
        '}', // 11
        'void mergeInPlace(List<int> arr, int left, int mid, int right) {', // 12
        '  int i = left;', // 13
        '  int j = mid + 1;', // 14
        '  while (i <= mid && j <= right) {', // 15
        '    if (arr[i] <= arr[j]) {', // 16
        '      i++;', // 17
        '    } else {', // 18
        '      int k = j;', // 19
        '      while (k > i) {', // 20
        '        int temp = arr[k];', // 21
        '        arr[k] = arr[k - 1];', // 22
        '        arr[k - 1] = temp;', // 23
        '        k--;', // 24
        '      }', // 25
        '      i++;', // 26
        '      mid++;', // 27
        '      j++;', // 28
        '    }', // 29
        '  }', // 30
        '}', // 31
      ];

  @override
  int codeLineForStep(SortingStep step) => switch (step.action) {
        SortingStatus.compared => 16, // arr[i] <= arr[j]
        SortingStatus.swapping => 22, // arr[k] = arr[k - 1]
        SortingStatus.none => 15, // advancing merge pointers
        _ => -1,
      };
}

/*
import 'dart:ui' show Offset;

import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:flutter/foundation.dart' show protected;

class MergeSortNotifier extends SortingNotifier {
  @override
  @protected
  Future<void> updateVisualizeSorting(
      {Future<(int, List<SortableItem>)> Function(int i, List<SortableItem> list)? temporaryActions}) async {
    return await super.updateVisualizeSorting(
      temporaryActions: (index, list) async {
        int i = index;
        final steps = state.sortedSteps;
        final tempList = list;
        Map<int, Offset> positions = Map<int, Offset>.from(state.positions);

        for (; i < steps.length && steps[i].action == SortingStatus.temporary;) {
          tempList[steps[i].index1] =
              tempList[steps[i].index1].copyWith(sortedStatus: SortingStatus.temporary);
          tempList[steps[i].index2] =
              tempList[steps[i].index2].copyWith(sortedStatus: SortingStatus.temporary);
          if (i + 1 < steps.length && steps[i + 1].action == SortingStatus.temporary) {
            i++;
          } else {
            break;
          }
        }
        state = state.copyWith(list: List.of(tempList), positions: positions, currentStep: steps[i]);

        await Future.delayed(speedDuration);
        await Future.delayed(speedDuration);

        if (i + 1 < steps.length && steps[i + 1].action == SortingStatus.none) i++;

        for (; i < steps.length && steps[i].action == SortingStatus.none;) {
          tempList[steps[i].index1] = tempList[steps[i].index1].copyWith(sortedStatus: SortingStatus.none);
          tempList[steps[i].index2] = tempList[steps[i].index2].copyWith(sortedStatus: SortingStatus.none);
          if (i + 1 < steps.length && steps[i + 1].action == SortingStatus.none) {
            i++;
          } else {
            break;
          }
        }
        state = state.copyWith(list: List.of(tempList), positions: positions, currentStep: steps[i]);
        await Future.delayed(speedDuration);
        await Future.delayed(speedDuration);

        return (i, List.of(tempList));
      },
    );
  }

  @override
  SortingResult buildSorting(List<int> values) {
    final steps = <SortingStep>[];
    final arr = List<int>.from(values);

    if (arr.isEmpty) return SortingResult(sortedValues: [], steps: []);

    if (arr.length == 1) {
      return SortingResult(
        steps: [SortingStep(index1: 0, index2: 0, action: SortingStatus.sorted)],
        sortedValues: [arr[0]],
      );
    }

    List<int> mergeTwoSortedLists(List<int> left, List<int> right) {
      final List<int> result = [];

      int leftIndex = 0;
      int rightIndex = 0;

      while (leftIndex < left.length && rightIndex < right.length) {
        if (left[leftIndex] < right[rightIndex]) {
          result.add(left[leftIndex]);
          leftIndex++;
        } else {
          result.add(right[rightIndex]);
          rightIndex++;
        }
      }

      while (leftIndex < left.length) {
        result.add(left[leftIndex]);
        leftIndex++;
      }
      while (rightIndex < right.length) {
        result.add(right[rightIndex]);
        rightIndex++;
      }

      return result;
    }

    List<int> mergeSort(List<int> arr, List<int> fullArr, bool? isLeft) {
      if (arr.isEmpty) return arr;

      if (arr.length <= 1) {
        // steps.add(SortingStep(
        //     index1: fullArr.indexOf(arr[0]), index2: fullArr.indexOf(arr[0]), action: SortingStatus.none));
        return arr;
      }
      final midIndex = arr.length ~/ 2;

      if (isLeft != false && midIndex > 1) {
        for (int i = 0; i < midIndex; i++) {
          steps.add(
              SortingStep(index1: i, index2: i + 1 < midIndex ? i + 1 : i, action: SortingStatus.temporary));
        }

        for (int i = 0; i < midIndex; i++) {
          steps.add(SortingStep(index1: i, index2: i + 1 < midIndex ? i + 1 : i, action: SortingStatus.none));
        }
      }

      final left = mergeSort(arr.sublist(0, midIndex), arr, true);

      if (isLeft == false&&midIndex>1) {
        for (int i = midIndex; i < arr.length; i++) {
          steps.add(
              SortingStep(index1: i, index2: i + 1 < arr.length ? i + 1 : i, action: SortingStatus.temporary));
        }

        for (int i = midIndex; i < arr.length; i++) {
          steps.add(SortingStep(index1: i, index2: i + 1 < arr.length ? i + 1 : i, action: SortingStatus.none));
        }
      }
      final right = mergeSort(arr.sublist(midIndex), arr, false);

      return mergeTwoSortedLists(left, right);
    }

    mergeSort(arr, arr, null);

    return SortingResult(sortedValues: arr, steps: steps);
  }

  static final algorithmComplexity = AlgorithmComplexity(
    name: StringsManager.mergeSort,
    bestTimeComplexity: ONotationComplexity.nLogN,
    averageTimeComplexity: ONotationComplexity.nLogN,
    worstTimeComplexity: ONotationComplexity.nLogN,
    spaceComplexity: ONotationComplexity.n,
    stable: true,
  );

  @override
  AlgorithmComplexity get algoComplexity => algorithmComplexity;

  @override
  String get algorithmDescription => StringsManager.mergeSortDescription;
  @override
  List<String> get codeSnippet => const [
        'void main() {', // 0
        '  List<int> arr = [64, 34, 25, 12, 22, 11, 90];', // 1
        '  mergeSort(arr, 0, arr.length - 1);', // 2
        '}', // 3
        'void mergeSort(List<int> arr, int left, int right) {', // 4
        '  if (left < right) {', // 5
        '    int mid = (left + right) >> 1;', // 6
        '    mergeSort(arr, left, mid);', // 7
        '    mergeSort(arr, mid + 1, right);', // 8
        '    mergeInPlace(arr, left, mid, right);', // 9
        '  }', // 10
        '}', // 11
        'void mergeInPlace(List<int> arr, int left, int mid, int right) {', // 12
        '  int i = left;', // 13
        '  int j = mid + 1;', // 14
        '  while (i <= mid && j <= right) {', // 15
        '    if (arr[i] <= arr[j]) {', // 16
        '      i++;', // 17
        '    } else {', // 18
        '      int k = j;', // 19
        '      while (k > i) {', // 20
        '        int temp = arr[k];', // 21
        '        arr[k] = arr[k - 1];', // 22
        '        arr[k - 1] = temp;', // 23
        '        k--;', // 24
        '      }', // 25
        '      i++;', // 26
        '      mid++;', // 27
        '      j++;', // 28
        '    }', // 29
        '  }', // 30
        '}', // 31
      ];

  @override
  int codeLineForStep(SortingStep step) => switch (step.action) {
        SortingStatus.compared => 16, // arr[i] <= arr[j]
        SortingStatus.swapping => 22, // arr[k] = arr[k - 1]
        SortingStatus.none => 15, // advancing merge pointers
        _ => -1,
      };
}

* */
