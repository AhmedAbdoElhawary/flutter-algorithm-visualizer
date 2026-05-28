import 'package:algorithm_visualizer/core/helpers/o_notation.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:collection/collection.dart';

class CountingSortNotifier extends SortingNotifier {
  @override
  SortingResult buildSorting(List<int> values) {
    final steps = <SortingStep>[];
    final arr = List<int>.from(values);

    if (arr.isEmpty) return SortingResult(sortedValues: arr, steps: steps);

    int maxVal = arr.reduce((a, b) => a > b ? a : b);
    int minVal = arr.reduce((a, b) => a < b ? a : b);
    int range = maxVal - minVal + 1;

    final count = List<int>.filled(range, 0);
    for (int i = 0; i < arr.length; i++) {
      count[arr[i] - minVal]++;
    }

    int index = 0;
    for (int i = 0; i < range; i++) {
      while (count[i] > 0) {
        int correctValue = i + minVal;

        if (arr[index] != correctValue) {
          int targetIndex = arr.indexOf(correctValue, index);

          steps.add(SortingStep(index1: index, index2: targetIndex, action: SortingStatus.swapping));
          arr.swap(index, targetIndex);
          steps.add(SortingStep(index1: index, index2: targetIndex, action: SortingStatus.swapped));
        }

        index++;
        count[i]--;
      }
    }

    steps.add(SortingStep(index1: arr.length - 1, index2: arr.length - 1, action: SortingStatus.sorted));

    return SortingResult(sortedValues: arr, steps: steps);
  }
  static final algorithmComplexity = AlgorithmComplexity(
    name: StringsManager.countingSort,
    bestTimeComplexity: ONotationComplexity.nPlusK,
    averageTimeComplexity: ONotationComplexity.nPlusK,
    worstTimeComplexity: ONotationComplexity.nPlusK,
    spaceComplexity: ONotationComplexity.nPlusK,
  );

  @override
  AlgorithmComplexity get algoComplexity => algorithmComplexity;

  @override
  String get description => StringsManager.countingSortDescription;
  @override
  List<String> get codeSnippet => const [
    'max = findMax(arr)',                  // 0
    'count = new array[0..max]',           // 1
    'for i from 0 to n-1',               // 2
    '  count[arr[i]]++',                  // 3
    'for i from 1 to max',               // 4
    '  count[i] += count[i-1]',          // 5  ← prefix sums
    'for i from n-1 downTo 0',           // 6
    '  out[count[arr[i]]-1] = arr[i]',   // 7
    '  count[arr[i]]--',                  // 8
    'copy out[] back to arr',             // 9
  ];

  @override
  int codeLineForStep(SortingStep step) => switch (step.action) {
    SortingStatus.compared                              => 3,  // counting occurrences
    SortingStatus.swapping                              => 7,  // writing to output array
    SortingStatus.swapped || SortingStatus.unSorted     => 6,  // advance placement loop
    SortingStatus.sorted                                => 9,  // copy output → arr
    _                                                   => -1,
  };
}
