import 'package:algorithm_visualizer/core/helpers/o_notation.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:collection/collection.dart';

class QuickSortNotifier extends SortingNotifier {
  @override
  SortingResult buildSorting(List<int> values) {
    final steps = <SortingStep>[];
    final arr = List<int>.from(values);

    int partition(int low, int high) {
      final pivot = arr[high];
      int i = low - 1;

      for (int j = low; j < high; j++) {
        steps.add(SortingStep(index1: j, index2: high, action: SortingStatus.compared));
        steps.add(SortingStep(index1: j, index2: high, action: SortingStatus.unSorted));

        if (arr[j] <= pivot) {
          i++;
          if (i != j) {
            steps.add(SortingStep(index1: i, index2: j, action: SortingStatus.swapping));
            arr.swap(i, j);
            steps.add(SortingStep(index1: i, index2: j, action: SortingStatus.swapped));
          }
        }
      }

      if (i + 1 != high) {
        steps.add(SortingStep(index1: i + 1, index2: high, action: SortingStatus.swapping));
        arr.swap(i + 1, high);
        steps.add(SortingStep(index1: i + 1, index2: high, action: SortingStatus.swapped));
      }

      return i + 1;
    }

    void quickSort(int low, int high) {
      if (low < high) {
        final pi = partition(low, high);
        quickSort(low, pi - 1);
        quickSort(pi + 1, high);
      }
    }

    if (arr.isNotEmpty) quickSort(0, arr.length - 1);

    return SortingResult(sortedValues: arr, steps: steps);
  }

  static final algorithmComplexity = AlgorithmComplexity(
    name: StringsManager.quickSort,
    bestTimeComplexity: ONotationComplexity.nLogN,
    averageTimeComplexity: ONotationComplexity.nLogN,
    worstTimeComplexity: ONotationComplexity.n2,
    spaceComplexity: ONotationComplexity.logN,
  );

  @override
  AlgorithmComplexity get algoComplexity => algorithmComplexity;

  @override
  String get description => StringsManager.quickSortDescription;


}
