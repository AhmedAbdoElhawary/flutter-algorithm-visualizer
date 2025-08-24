import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:collection/collection.dart';

class RadixSortNotifier extends SortingNotifier {
  @override
  SortingResult buildSorting(List<int> values) {
    final steps = <SortingStep>[];
    final arr = List<int>.from(values);

    int getMax(List<int> arr) {
      int maxVal = arr[0];
      for (int i = 1; i < arr.length; i++) {
        if (arr[i] > maxVal) maxVal = arr[i];
      }
      return maxVal;
    }

    void countSort(int exp) {
      final n = arr.length;
      final output = List<int>.filled(n, 0);
      final count = List<int>.filled(10, 0);

      // Count occurrences of digits
      for (int i = 0; i < n; i++) {
        int digit = (arr[i] ~/ exp) % 10;
        count[digit]++;
      }

      // Accumulate counts
      for (int i = 1; i < 10; i++) {
        count[i] += count[i - 1];
      }

      // Build output array (stable order)
      for (int i = n - 1; i >= 0; i--) {
        int digit = (arr[i] ~/ exp) % 10;
        output[count[digit] - 1] = arr[i];
        count[digit]--;
      }

      // Copy output back into arr with steps
      for (int i = 0; i < n; i++) {
        if (arr[i] != output[i]) {
          // Find where arr[i] should go
          int newVal = output[i];
          int oldIndex = arr.indexOf(newVal, i); // find next occurrence

          steps.add(SortingStep(index1: i, index2: oldIndex, action: SortingStatus.swapping));
          arr.swap(i, oldIndex);
          steps.add(SortingStep(index1: i, index2: oldIndex, action: SortingStatus.swapped));
        }
      }
    }

    final maxVal = getMax(arr);

    // Do counting sort for every digit
    for (int exp = 1; maxVal ~/ exp > 0; exp *= 10) {
      countSort(exp);
    }

    // Mark all sorted at the end
    steps.add(SortingStep(index1: arr.length - 1, index2: arr.length - 1, action: SortingStatus.sorted));

    return SortingResult(sortedValues: arr, steps: steps);
  }
}
