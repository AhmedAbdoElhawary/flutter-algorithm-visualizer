import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sorting_notifier.dart';

class MergeSortNotifier extends SortingNotifier {
  @override
  SortingNotifierState build() => SortingNotifier.initState();

  @override
  SortingResult buildSorting(List<int> values) {
    final steps = <SortingStep>[];
    final arr = List<int>.from(values);

    if (arr.isEmpty) return SortingResult(sortedValues: [], steps: []);

    if (arr.length == 1) {
      return SortingResult(
        steps: [SortingStep(index1: 0, index2: 0, action: SortingStatus.sorted)],
        sortedValues: [arr[0]],
      );
    }

    List<int> mergeTwoSortedLists(List<int> left, List<int> right) {
      final  List<int> result = [];

      int leftIndex = 0;
      int rightIndex = 0;

      while (leftIndex < left.length && rightIndex < right.length) {
        if (left[leftIndex] < right[rightIndex]) {
          result.add(left[leftIndex]);
          leftIndex++;
        } else {
          result.add(right[rightIndex]);
          rightIndex++;
        }
      }

      while (leftIndex < left.length) {
        result.add(left[leftIndex]);
        leftIndex++;
      }
      while (rightIndex < right.length) {
        result.add(right[rightIndex]);
        rightIndex++;
      }

      return result;
    }

    List<int> mergeSort(List<int> arr) {
      if (arr.length <= 1) return arr;
      final midIndex = arr.length ~/ 2;

      for(final i in arr.sublist(0,midIndex)){
        steps.add(SortingStep(index1: arr.indexOf(i), index2: arr.indexOf(i), action: SortingStatus.temporary));
      }

      final left = mergeSort(arr.sublist(0, midIndex));
      final right = mergeSort(arr.sublist(midIndex));

      return mergeTwoSortedLists(left, right);
    }

    mergeSort(arr);

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
  String get algorithmDescription => StringsManager.mergeSortDescription;
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
        SortingStatus.compared => 16, // arr[i] <= arr[j]
        SortingStatus.swapping => 22, // arr[k] = arr[k - 1]
        SortingStatus.none => 15, // advancing merge pointers
        _ => -1,
      };
}
