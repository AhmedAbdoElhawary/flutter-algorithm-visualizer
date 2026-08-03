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
        steps.add(SortingStep(index1: i, index2: j, action: SortingStatus.unSorted));

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
    'mergeSort(arr, left, right)',      // 0
    '  if left >= right: return',       // 1
    '  mid = (left + right) / 2',      // 2
    '  mergeSort(arr, left, mid)',      // 3
    '  mergeSort(arr, mid+1, right)',   // 4
    '  merge(left, mid, right)',        // 5
    '    while i < left, j < right',   // 6
    '    if arr[i] <= arr[j]',         // 7
    '      result ← arr[i++]',         // 8
    '    else result ← arr[j++]',      // 9
    '  copy result back to arr',        // 10
  ];

  @override
  int codeLineForStep(SortingStep step) => switch (step.action) {
    SortingStatus.compared                              => 7,  // comparing merge candidates
    SortingStatus.swapping                              => 8,  // writing into result buffer
    SortingStatus.swapped || SortingStatus.unSorted     => 6,  // advancing merge pointers
    SortingStatus.sorted                                => 10, // writing result back to arr
    _                                                   => -1,
  };
}
