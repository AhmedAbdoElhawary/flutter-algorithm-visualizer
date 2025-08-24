import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:collection/collection.dart';

class RadixSortNotifier extends SortingNotifier {
  @override
  SortingResult buildSorting(List<int> values) {
    final steps = <SortingStep>[];
    final arr = List<int>.from(values);

    if (arr.isEmpty) {
      return SortingResult(sortedValues: arr, steps: steps);
    }

    int maxVal = arr.reduce((a, b) => a > b ? a : b);

    // Perform counting sort for every digit
    for (int exp = 1; maxVal ~/ exp > 0; exp *= 10) {
      _countingSortByDigit(arr, exp, steps);
    }

    // Mark all as sorted
    steps.add(SortingStep(index1: arr.length - 1, index2: arr.length - 1, action: SortingStatus.sorted));

    return SortingResult(sortedValues: arr, steps: steps);
  }

  void _countingSortByDigit(List<int> arr, int exp, List<SortingStep> steps) {
    int n = arr.length;
    List<int> output = List<int>.filled(n, 0);
    List<int> count = List<int>.filled(10, 0);

    // 1. Count occurrences of digits
    for (int i = 0; i < n; i++) {
      int digit = (arr[i] ~/ exp) % 10;
      count[digit]++;
    }

    // 2. Compute prefix sums
    for (int i = 1; i < 10; i++) {
      count[i] += count[i - 1];
    }

    // 3. Build output array (stable order, so go from right to left)
    for (int i = n - 1; i >= 0; i--) {
      int digit = (arr[i] ~/ exp) % 10;
      output[count[digit] - 1] = arr[i];
      count[digit]--;
    }

    // 4. Copy back to arr + log steps
    for (int i = 0; i < n; i++) {
      if (arr[i] != output[i]) {
        int oldIndex = arr.indexOf(output[i], i);
        steps.add(SortingStep(index1: i, index2: oldIndex, action: SortingStatus.swapping));
        arr.swap(i, oldIndex);
        steps.add(SortingStep(index1: i, index2: oldIndex, action: SortingStatus.swapped));
      }
    }
  }
}
