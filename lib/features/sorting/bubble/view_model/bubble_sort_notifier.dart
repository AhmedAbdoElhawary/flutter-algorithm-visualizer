import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:collection/collection.dart';

class BubbleSortNotifier extends SortingNotifier {
  @override
  SortingResult buildSorting(List<int> values) {
    final steps = <SortingStep>[];
    final arr = List<int>.from(values);

    for (int i = 0; i < arr.length - 1; i++) {
      bool isSorted = true;

      for (int j = 0; j < arr.length - i - 1; j++) {
        steps.add(SortingStep(index1: j, index2: j + 1, action: SortingStatus.compared)); // external

        if (arr[j] > arr[j + 1]) {
          steps.add(SortingStep(index1: j, index2: j + 1, action: SortingStatus.swapping)); // external

          arr.swap(j, j + 1);
          isSorted = false;
        }

        steps.add(SortingStep(index1: j, index2: j + 1, action: SortingStatus.swapped)); // external
      }

      steps.add(SortingStep(
          index1: arr.length - i - 1, index2: arr.length - i - 1, action: SortingStatus.sorted)); // external

      if (isSorted) break;
    }

    return SortingResult(sortedValues: arr, steps: steps);
  }
}
