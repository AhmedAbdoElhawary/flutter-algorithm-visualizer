import 'package:algorithm_visualizer/core/helpers/o_notation.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:collection/collection.dart';

class MergeSortNotifier extends SortingNotifier {
  @override
  SortingResult buildSorting(List<int> values) {
    final steps = <SortingStep>[];
    final arr = List<int>.from(values);

    void mergeInPlace(int left, int mid, int right) {
      int i = left;
      int j = mid + 1;

      while (i <= mid && j <= right) {
        steps.add(SortingStep(index1: i, index2: j, action: SortingStatus.compared));
        steps.add(SortingStep(index1: i, index2: j, action: SortingStatus.none));

        if (arr[i] <= arr[j]) {
          i++;
        } else {
          int k = j;
          while (k > i) {
            steps.add(SortingStep(index1: k, index2: k - 1, action: SortingStatus.swapping));
            arr.swap(k, k - 1);
            steps.add(SortingStep(index1: k, index2: k - 1, action: SortingStatus.swapped));
            k--;
          }
          i++;
          mid++;
          j++;
        }
      }
    }

    void mergeSort(int left, int right) {
      if (left < right) {
        final mid = (left + right) >> 1;
        mergeSort(left, mid);
        mergeSort(mid + 1, right);
        mergeInPlace(left, mid, right);
      }
    }

    if (arr.isNotEmpty) mergeSort(0, arr.length - 1);

    return SortingResult(sortedValues: arr, steps: steps);
  }


  static final algorithmComplexity = AlgorithmComplexity(
    name: StringsManager.mergeSort,
    bestTimeComplexity: ONotationComplexity.nLogN,
    averageTimeComplexity: ONotationComplexity.nLogN,
    worstTimeComplexity: ONotationComplexity.nLogN,
    spaceComplexity: ONotationComplexity.n,
    stable: true,
  );

  @override
  AlgorithmComplexity get algoComplexity => algorithmComplexity;

  @override
  String get description => StringsManager.mergeSortDescription;
  @override
  List<String> get codeSnippet => const [
    'void main() {', // 0
    '  List<int> arr = [64, 34, 25, 12, 22, 11, 90];', // 1
    '  mergeSort(arr, 0, arr.length - 1);', // 2
    '}', // 3
    'void mergeSort(List<int> arr, int left, int right) {', // 4
    '  if (left < right) {', // 5
    '    int mid = (left + right) >> 1;', // 6
    '    mergeSort(arr, left, mid);', // 7
    '    mergeSort(arr, mid + 1, right);', // 8
    '    mergeInPlace(arr, left, mid, right);', // 9
    '  }', // 10
    '}', // 11
    'void mergeInPlace(List<int> arr, int left, int mid, int right) {', // 12
    '  int i = left;', // 13
    '  int j = mid + 1;', // 14
    '  while (i <= mid && j <= right) {', // 15
    '    if (arr[i] <= arr[j]) {', // 16
    '      i++;', // 17
    '    } else {', // 18
    '      int k = j;', // 19
    '      while (k > i) {', // 20
    '        int temp = arr[k];', // 21
    '        arr[k] = arr[k - 1];', // 22
    '        arr[k - 1] = temp;', // 23
    '        k--;', // 24
    '      }', // 25
    '      i++;', // 26
    '      mid++;', // 27
    '      j++;', // 28
    '    }', // 29
    '  }', // 30
    '}', // 31
  ];

  @override
  int codeLineForStep(SortingStep step) => switch (step.action) {
    SortingStatus.compared                              => 16, // arr[i] <= arr[j]
    SortingStatus.swapping                              => 22, // arr[k] = arr[k - 1]
    SortingStatus.swapped || SortingStatus.none     => 15, // advancing merge pointers
    SortingStatus.sorted                                => 22, // writing result back to arr
  };
}
