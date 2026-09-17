import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:collection/collection.dart';

class BubbleSortNotifier extends SortingNotifier {
  @override
  Set<SortRole> get roles => const {SortRole.sorted, SortRole.compare, SortRole.swap};

  @override
  SortingResult buildSorting(List<int> values) {
    final arr = List<int>.from(values);
    final ctx = RoleContext(roles);

    for (int i = 0; i < arr.length - 1; i++) {
      bool isSorted = true;

      for (int j = 0; j < arr.length - i - 1; j++) {
        ctx.emit(StepKind.compare, j, j + 1);

        if (arr[j] > arr[j + 1]) {
          arr.swap(j, j + 1);
          ctx.emit(StepKind.swap, j, j + 1);
          isSorted = false;
        }
      }

      if (isSorted) break;
    }

    return SortingResult(sortedValues: arr, steps: ctx.steps);
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
  int codeLineForStep(SortStep step) => switch (step.kind) {
        StepKind.compare => 6, // evaluating arr[j] > arr[j + 1]
        StepKind.swap => 8, // executing arr[j] = arr[j + 1]
        StepKind.write => -1, // bubble sort never writes
      };
}
