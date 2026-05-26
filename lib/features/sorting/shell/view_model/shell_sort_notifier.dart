import 'package:algorithm_visualizer/core/helpers/o_notation.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:collection/collection.dart';

class ShellSortNotifier extends SortingNotifier {
  @override
  SortingResult buildSorting(List<int> values) {
    final steps = <SortingStep>[];
    final arr = List<int>.from(values);
    int n = arr.length;

    for (int gap = n ~/ 2; gap > 0; gap ~/= 2) {
      for (int i = gap; i < n; i++) {
        int j = i;
        while (j >= gap) {
          steps.add(SortingStep(index1: j, index2: j - gap, action: SortingStatus.compared));
          steps.add(SortingStep(index1: j, index2: j - gap, action: SortingStatus.unSorted));

          if (arr[j] < arr[j - gap]) {
            steps.add(SortingStep(index1: j, index2: j - gap, action: SortingStatus.swapping));
            arr.swap(j, j - gap);
            steps.add(SortingStep(index1: j, index2: j - gap, action: SortingStatus.swapped));
          } else {
            break;
          }
          j -= gap;
        }
      }
    }

    steps.add(SortingStep(index1: arr.length - 1, index2: arr.length - 1, action: SortingStatus.sorted));

    return SortingResult(sortedValues: arr, steps: steps);
  }

  static final algorithmComplexity = AlgorithmComplexity(
    name: StringsManager.shellSort,
    bestTimeComplexity: ONotationComplexity.nLogN,
    averageTimeComplexity: ONotationComplexity.n2,
    worstTimeComplexity: ONotationComplexity.n2,
    spaceComplexity: ONotationComplexity.constant,
  );

  @override
  AlgorithmComplexity get algoComplexity => algorithmComplexity;

  @override
  String get description => StringsManager.shellSortDescription;

}
