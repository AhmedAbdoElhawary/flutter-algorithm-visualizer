import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:collection/collection.dart';


class InsertionSortNotifier extends SortingNotifier {

  @override
  SortingResult buildSorting(List<int> values) {
    final steps = <SortingStep>[];
    final arr = List<int>.from(values);

    for (int i = 1; i < arr.length; i++) {
      for (int j = i; j > 0; j--) {
        steps.add(SortingStep(index1: j, index2: j - 1, action: SortingStatus.compared));

        if (arr[j] < arr[j - 1]) {
          steps.add(SortingStep(index1: j, index2: j - 1, action: SortingStatus.swapping));

          arr.swap(j, j - 1);
        }else{
          break;
        }
      }
    }

    return SortingResult(sortedValues: arr, steps: steps);
  }

  static final algorithmComplexity = AlgorithmComplexity(
    name: StringsManager.insertionSort,
    bestTimeComplexity: ONotationComplexity.n,
    averageTimeComplexity: ONotationComplexity.n2,
    worstTimeComplexity: ONotationComplexity.n2,
    spaceComplexity: ONotationComplexity.constant,
    stable: true,
  );

  @override
  AlgorithmComplexity get algoComplexity => algorithmComplexity;

  @override
  String get algorithmDescription => StringsManager.insertionSortDescription;
  @override
  List<String> get codeSnippet => const [
        'void main() {', // 0
        '  List<int> arr = [64, 34, 25, 12, 22, 11, 90];', // 1
        '  for (int i = 1; i < arr.length; i++) {', // 2
        '    int j = i;', // 3
        '    while (j > 0 && arr[j] < arr[j - 1]) {', // 4
        '      int temp = arr[j];', // 5
        '      arr[j] = arr[j - 1];', // 6
        '      arr[j - 1] = temp;', // 7
        '      j--;', // 8
        '    }', // 9
        '  }', // 10
        '}', // 11
      ];

  @override
  int codeLineForStep(SortingStep step) => switch (step.action) {
        SortingStatus.compared => 4, // arr[j] < arr[j - 1]
        SortingStatus.swapping => 6, // arr[j] = arr[j - 1]
        SortingStatus.none => 8, // j--
        _ => -1,
      };
}
