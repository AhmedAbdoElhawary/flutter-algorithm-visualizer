import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:collection/collection.dart';

class MergeSortNotifier extends SortingNotifier {
  @override
  SortingResult buildSorting(List<int> values) {
    final steps = <SortingStep>[];
    final arr = List<int>.from(values);

    // In-place merge using adjacent swaps so it matches your 'swapping' handler.
    void mergeInPlace(int left, int mid, int right) {
      int i = left;
      int j = mid + 1;

      while (i <= mid && j <= right) {
        // Show comparison between current heads
        steps.add(SortingStep(index1: i, index2: j, action: SortingStatus.compared));
        // Clear highlight
        steps.add(SortingStep(index1: i, index2: j, action: SortingStatus.unSorted));

        if (arr[i] <= arr[j]) {
          i++;
        } else {
          // arr[j] should be inserted before arr[i].
          // Bubble arr[j] leftwards via adjacent swaps until it reaches i.
          int k = j;
          while (k > i) {
            steps.add(SortingStep(index1: k, index2: k - 1, action: SortingStatus.swapping));
            arr.swap(k, k - 1);

            // your handler clears to unSorted
            steps.add(SortingStep(index1: k, index2: k - 1, action: SortingStatus.swapped));
            k--;
          }
          // Now the element originally at j is at position i.
          i++;
          mid++; // left segment grew by one
          j++; // next element in right segment
        }
      }
    }

    void mergeSort(int left, int right) {
      if (left >= right) return;
      final mid = (left + right) >> 1;
      mergeSort(left, mid);
      mergeSort(mid + 1, right);
      mergeInPlace(left, mid, right);
    }

    if (arr.isNotEmpty) mergeSort(0, arr.length - 1);

    // No "sorted" marks during the run; your base class greens everything at the end.
    return SortingResult(sortedValues: arr, steps: steps);
  }
}
