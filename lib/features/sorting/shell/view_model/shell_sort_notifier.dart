import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:collection/collection.dart';

class ShellSortNotifier extends SortingNotifier {
  @override
  SortingResult buildSorting(List<int> values) {
    final steps = <SortingStep>[];
    final arr = List<int>.from(values);
    int n = arr.length;

    // Start with a big gap, then reduce
    for (int gap = n ~/ 2; gap > 0; gap ~/= 2) {
      // Do a gapped insertion sort
      for (int i = gap; i < n; i++) {
        int j = i;

        while (j >= gap && arr[j - gap] > arr[j]) {
          // Compare
          steps.add(SortingStep(index1: j, index2: j - gap, action: SortingStatus.compared));
          steps.add(SortingStep(index1: j, index2: j - gap, action: SortingStatus.unSorted));

          // Swap
          steps.add(SortingStep(index1: j, index2: j - gap, action: SortingStatus.swapping));
          arr.swap(j, j - gap);
          steps.add(SortingStep(index1: j, index2: j - gap, action: SortingStatus.swapped));

          j -= gap;
        }
      }
    }

    // Mark all sorted at the end
    steps.add(SortingStep(index1: arr.length - 1, index2: arr.length - 1, action: SortingStatus.sorted));

    return SortingResult(sortedValues: arr, steps: steps);
  }
}
