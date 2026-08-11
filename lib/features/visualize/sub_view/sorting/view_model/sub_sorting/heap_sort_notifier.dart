import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sorting_notifier.dart';
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
        steps.add(SortingStep(index1: i, index2: left, action: SortingStatus.none));
        if (arr[left] > arr[largest]) {
          largest = left;
        }
      }

      if (right < n) {
        steps.add(SortingStep(index1: i, index2: right, action: SortingStatus.compared));
        steps.add(SortingStep(index1: i, index2: right, action: SortingStatus.none));
        if (arr[right] > arr[largest]) {
          largest = right;
        }
      }

      if (largest != i) {
        steps.add(SortingStep(index1: i, index2: largest, action: SortingStatus.swapping));
        arr.swap(i, largest);

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

        heapify(i, 0);
      }
    }

    if (arr.isNotEmpty) heapSort();

    return SortingResult(sortedValues: arr, steps: steps);
  }

  static final algorithmComplexity = AlgorithmComplexity(
    name: StringsManager.heapSort,
    bestTimeComplexity: ONotationComplexity.nLogN,
    averageTimeComplexity: ONotationComplexity.nLogN,
    worstTimeComplexity: ONotationComplexity.nLogN,
    spaceComplexity: ONotationComplexity.constant,
    stable: false,
  );

  @override
  AlgorithmComplexity get algoComplexity => algorithmComplexity;

  @override
  String get algorithmDescription => StringsManager.heapSortDescription;
  @override
  List<String> get codeSnippet => const [
        'void main() {', // 0
        '  List<int> arr = [64, 34, 25, 12, 22, 11, 90];', // 1
        '  int n = arr.length;', // 2
        '  for (int i = (n ~/ 2) - 1; i >= 0; i--) {', // 3
        '    heapify(arr, n, i);', // 4
        '  }', // 5
        '  for (int i = n - 1; i > 0; i--) {', // 6
        '    int temp = arr[0];', // 7
        '    arr[0] = arr[i];', // 8
        '    arr[i] = temp;', // 9
        '    heapify(arr, i, 0);', // 10
        '  }', // 11
        '}', // 12
        'void heapify(List<int> arr, int n, int i) {', // 13
        '  int largest = i;', // 14
        '  int left = 2 * i + 1;', // 15
        '  int right = 2 * i + 2;', // 16
        '  if (left < n && arr[left] > arr[largest]) {', // 17
        '    largest = left;', // 18
        '  }', // 19
        '  if (right < n && arr[right] > arr[largest]) {', // 20
        '    largest = right;', // 21
        '  }', // 22
        '  if (largest != i) {', // 23
        '    int temp = arr[i];', // 24
        '    arr[i] = arr[largest];', // 25
        '    arr[largest] = temp;', // 26
        '    heapify(arr, n, largest);', // 27
        '  }', // 28
        '}', // 29
      ];

  @override
  int codeLineForStep(SortingStep step) => switch (step.action) {
        SortingStatus.compared => 17, // arr[left] > arr[largest]
        SortingStatus.swapping => 25, // arr[i] = arr[largest]
        SortingStatus.none => 23, // check if swap needed
        _ => -1,
      };
}
