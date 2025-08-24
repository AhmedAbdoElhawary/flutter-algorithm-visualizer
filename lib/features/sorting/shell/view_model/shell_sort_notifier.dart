import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:collection/collection.dart';

class ShellSortNotifier extends SortingNotifier {
  @override
  SortingResult buildSorting(List<int> values) {
    final steps = <SortingStep>[];
    final arr = List<int>.from(values);
    final n = arr.length;

    // Knuth gap sequence: 1, 4, 13, 40, ...
    int gap = 1;
    while (gap < n ~/ 3) {
      gap = 3 * gap + 1;
    }

    for (; gap >= 1; gap = (gap - 1) ~/ 3) {
      for (int i = gap; i < n; i++) {
        int j = i;
        // Gapped insertion via adjacent swaps (with step logs)
        while (j >= gap) {
          steps.add(SortingStep(index1: j, index2: j - gap, action: SortingStatus.compared));
          steps.add(SortingStep(index1: j, index2: j - gap, action: SortingStatus.unSorted));

          if (arr[j] < arr[j - gap]) {
            steps.add(SortingStep(index1: j, index2: j - gap, action: SortingStatus.swapping));
            arr.swap(j, j - gap);
            steps.add(SortingStep(index1: j, index2: j - gap, action: SortingStatus.swapped));
            j -= gap;
          } else {
            break;
          }
        }
      }
    }

    return SortingResult(sortedValues: arr, steps: steps);
  }
}
