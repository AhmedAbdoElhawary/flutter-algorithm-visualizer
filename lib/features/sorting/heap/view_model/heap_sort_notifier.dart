import 'package:algorithm_visualizer/core/helpers/o_notation.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:collection/collection.dart';

class HeapSortNotifier extends SortingNotifier {
  @override
  SortingResult buildSorting(List<int> values) {
    final steps = <SortingStep>[];
    final arr = List<int>.from(values);

    void heapify(int n, int i) {
      int largest = i;
      int left = 2 * i + 1;
      int right = 2 * i + 2;

      if (left < n) {
        steps.add(SortingStep(index1: i, index2: left, action: SortingStatus.compared));
        steps.add(SortingStep(index1: i, index2: left, action: SortingStatus.unSorted));
        if (arr[left] > arr[largest]) {
          largest = left;
        }
      }

      if (right < n) {
        steps.add(SortingStep(index1: i, index2: right, action: SortingStatus.compared));
        steps.add(SortingStep(index1: i, index2: right, action: SortingStatus.unSorted));
        if (arr[right] > arr[largest]) {
          largest = right;
        }
      }

      if (largest != i) {
        steps.add(SortingStep(index1: i, index2: largest, action: SortingStatus.swapping));
        arr.swap(i, largest);
        steps.add(SortingStep(index1: i, index2: largest, action: SortingStatus.swapped));

        heapify(n, largest);
      }
    }

    void heapSort() {
      int n = arr.length;

      for (int i = (n ~/ 2) - 1; i >= 0; i--) {
        heapify(n, i);
      }

      for (int i = n - 1; i > 0; i--) {
        steps.add(SortingStep(index1: 0, index2: i, action: SortingStatus.swapping));
        arr.swap(0, i);
        steps.add(SortingStep(index1: 0, index2: i, action: SortingStatus.swapped));

        heapify(i, 0);
      }
    }

    if (arr.isNotEmpty) heapSort();
    steps.add(SortingStep(index1: 0, index2: 0, action: SortingStatus.sorted));

    return SortingResult(sortedValues: arr, steps: steps);
  }



  static final algorithmComplexity = AlgorithmComplexity(
    name: StringsManager.heapSort,
    bestTimeComplexity: ONotationComplexity.nLogN,
    averageTimeComplexity: ONotationComplexity.nLogN,
    worstTimeComplexity: ONotationComplexity.nLogN,
    spaceComplexity: ONotationComplexity.constant,
  );

  @override
  AlgorithmComplexity get algoComplexity => algorithmComplexity;

  @override
  String get description => StringsManager.heapSortDescription;
  @override
  List<String> get codeSnippet => const [
    'buildMaxHeap(arr)',                    // 0
    '  for i from n/2-1 downTo 0',         // 1
    '    heapify(arr, n, i)',               // 2
    'for i from n-1 downTo 1',             // 3
    '  swap(arr[0], arr[i])',              // 4
    '  heapify(arr, i, 0)',                // 5
    '    largest = parent',                // 6
    '    if child > arr[largest]',         // 7
    '      largest = child index',         // 8
    '    if largest != parent',            // 9
    '      swap(arr[parent], arr[largest])',// 10
  ];

  @override
  int codeLineForStep(SortingStep step) => switch (step.action) {
    SortingStatus.compared                              => 7,  // child vs largest
    SortingStatus.swapping                              => 10, // heapify swap
    SortingStatus.swapped || SortingStatus.unSorted     => 9,  // check if swap needed
    SortingStatus.sorted                                => 4,  // extract max to end
    _                                                   => -1,
  };
}
