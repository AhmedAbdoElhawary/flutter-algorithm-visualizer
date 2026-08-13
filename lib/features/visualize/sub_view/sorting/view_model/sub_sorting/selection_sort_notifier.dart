import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sorting_notifier.dart';
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

        steps.add(SortingStep(index1: minIndex, index2: j, action: SortingStatus.none));
      }

      if (minIndex != i) {
        steps.add(SortingStep(index1: i, index2: minIndex, action: SortingStatus.swapping));

        arr.swap(minIndex, i);
      }
    }

    return SortingResult(sortedValues: arr, steps: steps);
  }

  static final algorithmComplexity = AlgorithmComplexity(
    name: StringsManager.selectionSort,
    bestTimeComplexity: ONotationComplexity.n2,
    averageTimeComplexity: ONotationComplexity.n2,
    worstTimeComplexity: ONotationComplexity.n2,
    spaceComplexity: ONotationComplexity.constant,
    stable: false,
  );

  @override
  AlgorithmComplexity get algoComplexity => algorithmComplexity;

  @override
  String get algorithmDescription => StringsManager.selectionSortDescription;
  @override
  List<String> get codeSnippet => const [
        'void main() {', // 0
        '  List<int> arr = [64, 34, 25, 12, 22, 11, 90];', // 1
        '  for (int i = 0; i < arr.length - 1; i++) {', // 2
        '    int minIndex = i;', // 3
        '    for (int j = i + 1; j < arr.length; j++) {', // 4
        '      if (arr[j] < arr[minIndex]) {', // 5
        '        minIndex = j;', // 6
        '      }', // 7
        '    }', // 8
        '    if (minIndex != i) {', // 9
        '      int temp = arr[i];', // 10
        '      arr[i] = arr[minIndex];', // 11
        '      arr[minIndex] = temp;', // 12
        '    }', // 13
        '  }', // 14
        '}', // 15
      ];

  @override
  int codeLineForStep(SortingStep step) => switch (step.action) {
        SortingStatus.compared => 5, // arr[j] < arr[minIndex]
        SortingStatus.swapping => 11, // arr[i] = arr[minIndex]
        SortingStatus.none => 4, // advance inner loop
        _ => -1,
      };
}
