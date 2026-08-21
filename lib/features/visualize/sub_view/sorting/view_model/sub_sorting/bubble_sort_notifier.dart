import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:collection/collection.dart';

class BubbleSortNotifier extends SortingNotifier {
  @override
  SortingNotifierState build() => SortingNotifier.initState();

  @override
  SortingResult buildSorting(List<int> values) {
    final steps = <SortingStep>[];
    final arr = List<int>.from(values);

    for (int i = 0; i < arr.length - 1; i++) {
      bool isSorted = true;

      for (int j = 0; j < arr.length - i - 1; j++) {
        steps.add(SortingStep(index1: j, index2: j + 1, action: SortingStatus.compared)); // external

        if (arr[j] > arr[j + 1]) {
          steps.add(SortingStep(index1: j, index2: j + 1, action: SortingStatus.swapping)); // external

          arr.swap(j, j + 1);
          isSorted = false;
        }
      }

      if (isSorted) break;
    }

    return SortingResult(sortedValues: arr, steps: steps);
  }

  static final algorithmComplexity = AlgorithmComplexity(
    name: StringsManager.bubbleSort,
    bestTimeComplexity: ONotationComplexity.n,
    averageTimeComplexity: ONotationComplexity.n2,
    worstTimeComplexity: ONotationComplexity.n2,
    spaceComplexity: ONotationComplexity.constant,
    stable: true,
  );

  @override
  AlgorithmComplexity get algoComplexity => algorithmComplexity;

  @override
  String get algorithmDescription => StringsManager.bubbleSortDescription;

  @override
  List<String> get codeSnippet => const [
        'void main() {', // 0
        '  List<int> arr = [64, 34, 25, 12, 22, 11, 90];', // 1
        '  int n = arr.length;', // 2
        '  for (int i = 0; i < n - 1; i++) {', // 3
        '    bool isSorted = true;', // 4
        '    for (int j = 0; j < n - i - 1; j++) {', // 5
        '      if (arr[j] > arr[j + 1]) {', // 6
        '        int temp = arr[j];', // 7
        '        arr[j] = arr[j + 1];', // 8
        '        arr[j + 1] = temp;', // 9
        '        isSorted = false;', // 10
        '      }', // 11
        '    }', // 12
        '    if (isSorted) break;', // 13
        '  }', // 14
        '}', // 15
      ];

  @override
  int codeLineForStep(SortingStep step) => switch (step.action) {
        SortingStatus.compared => 6, // evaluating arr[j] > arr[j + 1]
        SortingStatus.swapping => 8, // executing arr[j] = arr[j + 1]
        SortingStatus.none => 5, // continuing the inner loop
        _ => -1,
      };
}
