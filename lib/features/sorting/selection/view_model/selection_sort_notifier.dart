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
  @override
  List<String> get codeSnippet => const [
    'for i from 0 to n-2',             // 0
    '  minIdx = i',                    // 1
    '  for j from i+1 to n-1',        // 2
    '    if arr[j] < arr[minIdx]',     // 3
    '      minIdx = j',                // 4
    '  if minIdx != i',                // 5
    '    swap(arr[i], arr[minIdx])',   // 6
  ];

  @override
  int codeLineForStep(SortingStep step) => switch (step.action) {
    SortingStatus.compared                              => 3, // comparing with current min
    SortingStatus.swapping                              => 6, // swap min into place
    SortingStatus.swapped || SortingStatus.unSorted     => 2, // advance inner loop
    SortingStatus.sorted                                => 5, // verify min changed
    _                                                   => -1,
  };
}
