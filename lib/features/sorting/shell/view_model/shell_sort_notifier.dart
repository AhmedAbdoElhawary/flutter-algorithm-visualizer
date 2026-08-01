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
    stable: false,
  );

  @override
  AlgorithmComplexity get algoComplexity => algorithmComplexity;

  @override
  String get description => StringsManager.shellSortDescription;
  @override
  List<String> get codeSnippet => const [
    'gap = n / 2',                      // 0
    'while gap > 0',                    // 1
    '  for i from gap to n-1',         // 2
    '    temp = arr[i]',                // 3
    '    j = i',                        // 4
    '    while j >= gap',               // 5
    '      and arr[j-gap] > temp',      // 6
    '      arr[j] = arr[j-gap]',        // 7
    '      j -= gap',                   // 8
    '    arr[j] = temp',                // 9
    '  gap = gap / 2',                  // 10
  ];

  @override
  int codeLineForStep(SortingStep step) => switch (step.action) {
    SortingStatus.compared                              => 6,  // arr[j-gap] > temp
    SortingStatus.swapping                              => 7,  // shift element right
    SortingStatus.swapped || SortingStatus.unSorted     => 8,  // j -= gap
    SortingStatus.sorted                                => 9,  // arr[j] = temp (placed)
    _                                                   => -1,
  };
}
