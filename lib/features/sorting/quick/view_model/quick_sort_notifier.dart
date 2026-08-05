import 'package:algorithm_visualizer/core/helpers/o_notation.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:collection/collection.dart';

class QuickSortNotifier extends SortingNotifier {
  @override
  SortingResult buildSorting(List<int> values) {
    final steps = <SortingStep>[];
    final arr = List<int>.from(values);

    int partition(int low, int high) {
      final pivot = arr[high];
      int i = low - 1;

      for (int j = low; j < high; j++) {
        steps.add(SortingStep(index1: j, index2: high, action: SortingStatus.compared));
        steps.add(SortingStep(index1: j, index2: high, action: SortingStatus.none));

        if (arr[j] <= pivot) {
          i++;
          if (i != j) {
            steps.add(SortingStep(index1: i, index2: j, action: SortingStatus.swapping));
            arr.swap(i, j);
          }
        }
      }

      if (i + 1 != high) {
        steps.add(SortingStep(index1: i + 1, index2: high, action: SortingStatus.swapping));
        arr.swap(i + 1, high);
      }

      return i + 1;
    }

    void quickSort(int low, int high) {
      if (low < high) {
        final pi = partition(low, high);
        quickSort(low, pi - 1);
        quickSort(pi + 1, high);
      }
    }

    if (arr.isNotEmpty) quickSort(0, arr.length - 1);

    return SortingResult(sortedValues: arr, steps: steps);
  }

  static final algorithmComplexity = AlgorithmComplexity(
    name: StringsManager.quickSort,
    bestTimeComplexity: ONotationComplexity.nLogN,
    averageTimeComplexity: ONotationComplexity.nLogN,
    worstTimeComplexity: ONotationComplexity.n2,
    spaceComplexity: ONotationComplexity.logN,
    stable: false,
  );

  @override
  AlgorithmComplexity get algoComplexity => algorithmComplexity;

  @override
  String get algorithmDescription => StringsManager.quickSortDescription;
  @override
  List<String> get codeSnippet => const [
    'void main() {', // 0
    '  List<int> arr = [64, 34, 25, 12, 22, 11, 90];', // 1
    '  quickSort(arr, 0, arr.length - 1);', // 2
    '}', // 3
    'void quickSort(List<int> arr, int low, int high) {', // 4
    '  if (low < high) {', // 5
    '    int pi = partition(arr, low, high);', // 6
    '    quickSort(arr, low, pi - 1);', // 7
    '    quickSort(arr, pi + 1, high);', // 8
    '  }', // 9
    '}', // 10
    'int partition(List<int> arr, int low, int high) {', // 11
    '  int pivot = arr[high];', // 12
    '  int i = low - 1;', // 13
    '  for (int j = low; j < high; j++) {', // 14
    '    if (arr[j] <= pivot) {', // 15
    '      i++;', // 16
    '      if (i != j) {', // 17
    '        int temp = arr[i];', // 18
    '        arr[i] = arr[j];', // 19
    '        arr[j] = temp;', // 20
    '      }', // 21
    '    }', // 22
    '  }', // 23
    '  if (i + 1 != high) {', // 24
    '    int temp = arr[i + 1];', // 25
    '    arr[i + 1] = arr[high];', // 26
    '    arr[high] = temp;', // 27
    '  }', // 28
    '  return i + 1;', // 29
    '}', // 30
  ];

  @override
  int codeLineForStep(SortingStep step) => switch (step.action) {
    SortingStatus.compared                              => 15, // arr[j] <= pivot
    SortingStatus.swapping                              => 19, // arr[i] = arr[j]
 SortingStatus.none     => 14, // advance j
    _ => -1,
  };

}
