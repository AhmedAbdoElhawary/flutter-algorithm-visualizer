import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:collection/collection.dart';

class MergeSortNotifier extends SortingNotifier {
  @override
  SortingResult buildSorting(List<int> values) {
    final steps = <SortingStep>[];
    final arr = List<int>.from(values);

    void mergeInPlace(int left, int mid, int right) {
      int i = left;
      int j = mid + 1;

      while (i <= mid && j <= right) {
        // Compare current elements
        steps.add(SortingStep(index1: i, index2: j, action: SortingStatus.compared));
        steps.add(SortingStep(index1: i, index2: j, action: SortingStatus.unSorted));

        if (arr[i] <= arr[j]) {
          i++;
        } else {
          // Bubble arr[j] left until it reaches position i
          int k = j;
          while (k > i) {
            steps.add(SortingStep(index1: k, index2: k - 1, action: SortingStatus.swapping));
            arr.swap(k, k - 1);
            steps.add(SortingStep(index1: k, index2: k - 1, action: SortingStatus.swapped));
            k--;
          }
          i++;
          mid++;
          j++;
        }
      }
    }

    void mergeSort(int left, int right) {
      if (left < right) {
        final mid = (left + right) >> 1;
        mergeSort(left, mid);
        mergeSort(mid + 1, right);
        mergeInPlace(left, mid, right);
      }
    }

    if (arr.isNotEmpty) mergeSort(0, arr.length - 1);

    return SortingResult(sortedValues: arr, steps: steps);
  }
}
