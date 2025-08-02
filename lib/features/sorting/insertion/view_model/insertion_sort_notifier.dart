import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:collection/collection.dart';

class InsertionSortNotifier extends SortingNotifier {
  @override
  SortingResult buildSorting(List<int> values) {
    final steps = <SortingStep>[];
    final arr = List<int>.from(values);

    for (int i = 1; i < arr.length; i++) {
      int j = i;

      while (j > 0 && arr[j] < arr[j - 1]) {
        steps.add(SortingStep(index1: j, index2: j - 1, action: SortingStatus.compared));
        steps.add(SortingStep(index1: j, index2: j - 1, action: SortingStatus.swapping));

        arr.swap(j, j - 1);
        steps.add(SortingStep(index1: j, index2: j - 1, action: SortingStatus.swapped));
        j--;
      }
      steps.add(SortingStep(index1: j, index2: j, action: SortingStatus.sorted));
    }

    steps.add(SortingStep(index1: arr.length - 1, index2: arr.length - 1, action: SortingStatus.sorted));

    return SortingResult(sortedValues: arr, steps: steps);
  }
}
