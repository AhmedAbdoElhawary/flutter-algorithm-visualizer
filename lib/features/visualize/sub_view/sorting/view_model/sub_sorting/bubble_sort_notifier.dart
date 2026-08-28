import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:collection/collection.dart';

class BubbleSortNotifier extends SortingNotifier {
  @override
  SortingResult buildSorting(List<int> values) {
    final steps = <SortingStep>[];
    final arr = List<int>.from(values);

    for (int i = 0; i < arr.length - 1; i++) {
      bool isSorted = true;

      for (int j = 0; j < arr.length - i - 1; j++) {
        steps.add(SortingStep(index1: j, index2: j + 1, action: SortingStatus.compared));

        if (arr[j] > arr[j + 1]) {
          steps.add(SortingStep(index1: j, index2: j + 1, action: SortingStatus.swapping));

          arr.swap(j, j + 1);
          isSorted = false;
        }
      }

      if (isSorted) break;
    }

    return SortingResult(sortedValues: arr, steps: steps);
  }

  List<int> bubbleSort(List<int> arr) {
    for (int i = 0; i < arr.length - 1; i++) {
      bool isSorted = true;

      for (int j = 0; j < arr.length - i - 1; j++) {
        if (arr[j] > arr[j + 1]) {
          arr.swap(j, j + 1);
          isSorted = false;
        }
      }

      if (isSorted) break;
    }

    return arr;
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
        "List<int> bubbleSort(List<int> arr) {",
        "  for (int i = 0; i < arr.length - 1; i++) {",
        "    bool isSorted = true;",
        "    for (int j = 0; j < arr.length - i - 1; j++) {",
        "      if (arr[j] > arr[j + 1]) {",
        "        arr.swap(j, j + 1);",
        "        isSorted = false;",
        "      }",
        "    }",
        "    if (isSorted) break;",
        "  }",
        "  return arr;",
        "}",
      ];

  @override
  int codeLineForStep(SortingStep step) => switch (step.action) {
        SortingStatus.compared => 6, // evaluating arr[j] > arr[j + 1]
        SortingStatus.swapping => 8, // executing arr[j] = arr[j + 1]
        SortingStatus.none => 5, // continuing the inner loop
        _ => -1,
      };
}
