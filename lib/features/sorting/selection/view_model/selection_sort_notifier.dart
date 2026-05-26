import 'package:algorithm_visualizer/core/helpers/o_notation.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:collection/collection.dart';

class SelectionSortNotifier extends SortingNotifier {
  @override
  SortingResult buildSorting(List<int> values) {
    final steps = <SortingStep>[];
    final arr = List<int>.from(values);

    for (int i = 0; i < arr.length - 1; i++) {
      int minIndex = i;

      for (int j = i + 1; j < arr.length; j++) {
        steps.add(SortingStep(index1: minIndex, index2: j, action: SortingStatus.compared));

        if (arr[j] < arr[minIndex]) {
          final previousIndex = minIndex;
          if (minIndex != i) {
            steps.add(SortingStep(index1: previousIndex, index2: previousIndex, action: SortingStatus.none));
          }
          minIndex = j;
        }

        steps.add(SortingStep(index1: minIndex, index2: j, action: SortingStatus.unSorted));
      }

      if (minIndex != i) {
        steps.add(SortingStep(index1: i, index2: minIndex, action: SortingStatus.swapping));

        arr.swap(minIndex, i);

        steps.add(SortingStep(index1: minIndex, index2: i, action: SortingStatus.swapped));
      }

      steps.add(SortingStep(index1: i, index2: i, action: SortingStatus.sorted));
    }

    steps.add(SortingStep(index1: arr.length - 1, index2: arr.length - 1, action: SortingStatus.sorted));

    return SortingResult(sortedValues: arr, steps: steps);
  }

  static final algorithmComplexity = AlgorithmComplexity(
    name: StringsManager.selectionSort,
    bestTimeComplexity: ONotationComplexity.n2,
    averageTimeComplexity: ONotationComplexity.n2,
    worstTimeComplexity: ONotationComplexity.n2,
    spaceComplexity: ONotationComplexity.constant,
  );

  @override
  AlgorithmComplexity get algoComplexity => algorithmComplexity;

  @override
  String get description => StringsManager.selectionSortDescription;

}
