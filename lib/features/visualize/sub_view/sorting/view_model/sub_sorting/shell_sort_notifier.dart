import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sorting_notifier.dart';
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
          steps.add(SortingStep(index1: j, index2: j - gap, action: SortingStatus.none));

          if (arr[j] < arr[j - gap]) {
            steps.add(SortingStep(index1: j, index2: j - gap, action: SortingStatus.swapping));
            arr.swap(j, j - gap);
          } else {
            break;
          }
          j -= gap;
        }
      }
    }

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
  String get algorithmDescription => StringsManager.shellSortDescription;
  @override
  List<String> get codeSnippet => const [
        'void main() {', // 0
        '  List<int> arr = [64, 34, 25, 12, 22, 11, 90];', // 1
        '  int n = arr.length;', // 2
        '  for (int gap = n ~/ 2; gap > 0; gap ~/= 2) {', // 3
        '    for (int i = gap; i < n; i++) {', // 4
        '      int j = i;', // 5
        '      while (j >= gap) {', // 6
        '        if (arr[j] < arr[j - gap]) {', // 7
        '          int temp = arr[j];', // 8
        '          arr[j] = arr[j - gap];', // 9
        '          arr[j - gap] = temp;', // 10
        '          j -= gap;', // 11
        '        } else {', // 12
        '          break;', // 13
        '        }', // 14
        '      }', // 15
        '    }', // 16
        '  }', // 17
        '}', // 18
      ];

  @override
  int codeLineForStep(SortingStep step) => switch (step.action) {
        SortingStatus.compared => 7, // arr[j] < arr[j - gap]
        SortingStatus.swapping => 9, // arr[j] = arr[j - gap]
        SortingStatus.none => 11, // j -= gap
        _ => -1,
      };
}
