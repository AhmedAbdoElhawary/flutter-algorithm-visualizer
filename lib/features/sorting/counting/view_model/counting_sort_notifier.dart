import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:collection/collection.dart';

class CountingSortNotifier extends SortingNotifier {
  @override
  SortingResult buildSorting(List<int> values) {
    final steps = <SortingStep>[];
    final arr = List<int>.from(values);

    if (arr.isEmpty) {
      return SortingResult(sortedValues: arr, steps: steps);
    }

    // 1. Find range of input values
    int maxVal = arr.reduce((a, b) => a > b ? a : b);
    int minVal = arr.reduce((a, b) => a < b ? a : b);
    int range = maxVal - minVal + 1;

    // 2. Frequency array
    final count = List<int>.filled(range, 0);
    for (int i = 0; i < arr.length; i++) {
      count[arr[i] - minVal]++;
    }

    // 3. Build the sorted array
    int index = 0;
    for (int i = 0; i < range; i++) {
      while (count[i] > 0) {
        int correctValue = i + minVal;

        if (arr[index] != correctValue) {
          // Find where the correctValue currently is
          int targetIndex = arr.indexOf(correctValue, index);

          // Log swap
          steps.add(SortingStep(index1: index, index2: targetIndex, action: SortingStatus.swapping));
          arr.swap(index, targetIndex);
          steps.add(SortingStep(index1: index, index2: targetIndex, action: SortingStatus.swapped));
        }

        index++;
        count[i]--;
      }
    }

    // Mark all sorted at the end
    steps.add(SortingStep(index1: arr.length - 1, index2: arr.length - 1, action: SortingStatus.sorted));

    return SortingResult(sortedValues: arr, steps: steps);
  }
}
