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
    stable: true,
  );

  @override
  AlgorithmComplexity get algoComplexity => algorithmComplexity;

  @override
  String get description => StringsManager.countingSortDescription;
  @override
  List<String> get codeSnippet => const [
    'void main() {', // 0
    '  List<int> arr = [64, 34, 25, 12, 22, 11, 90];', // 1
    '  int maxVal = arr.reduce((a, b) => a > b ? a : b);', // 2
    '  int minVal = arr.reduce((a, b) => a < b ? a : b);', // 3
    '  int range = maxVal - minVal + 1;', // 4
    '  List<int> count = List<int>.filled(range, 0);', // 5
    '  for (int i = 0; i < arr.length; i++) {', // 6
    '    count[arr[i] - minVal]++;', // 7
    '  }', // 8
    '  int index = 0;', // 9
    '  for (int i = 0; i < range; i++) {', // 10
    '    while (count[i] > 0) {', // 11
    '      arr[index++] = i + minVal;', // 12
    '      count[i]--;', // 13
    '    }', // 14
    '  }', // 15
    '}', // 16
  ];

  @override
  int codeLineForStep(SortingStep step) => switch (step.action) {
    SortingStatus.compared                              => 7,  // counting occurrences
    SortingStatus.swapping                              => 12, // writing to arr
    SortingStatus.swapped || SortingStatus.none     => 10, // advance placement loop
    SortingStatus.sorted                                => 12, // copy output → arr
  };
}
