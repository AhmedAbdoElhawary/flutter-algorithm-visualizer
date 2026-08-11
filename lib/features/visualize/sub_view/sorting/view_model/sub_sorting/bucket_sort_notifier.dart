import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:collection/collection.dart';

class BucketSortNotifier extends SortingNotifier {
  @override
  SortingResult buildSorting(List<int> values) {
    final steps = <SortingStep>[];
    final arr = List<int>.from(values);

    if (arr.isEmpty) {
      return SortingResult(sortedValues: arr, steps: steps);
    }

    int n = arr.length;
    int maxVal = arr.reduce((a, b) => a > b ? a : b);
    int minVal = arr.reduce((a, b) => a < b ? a : b);

    int bucketCount = n;
    double bucketRange = (maxVal - minVal + 1) / bucketCount;

    final buckets = List.generate(bucketCount, (_) => <int>[]);

    for (int value in arr) {
      int bucketIndex = ((value - minVal) / bucketRange).floor();
      if (bucketIndex >= bucketCount) bucketIndex = bucketCount - 1;
      buckets[bucketIndex].add(value);
    }

    for (var bucket in buckets) {
      for (int i = 1; i < bucket.length; i++) {
        int key = bucket[i];
        int j = i - 1;
        while (j >= 0 && bucket[j] > key) {
          bucket[j + 1] = bucket[j];
          j--;
        }
        bucket[j + 1] = key;
      }
    }

    int index = 0;
    for (var bucket in buckets) {
      for (int value in bucket) {
        if (arr[index] != value) {
          // Find where the value currently is
          int targetIndex = arr.indexOf(value, index);

          // Swap for visualization
          steps.add(SortingStep(index1: index, index2: targetIndex, action: SortingStatus.swapping));
          arr.swap(index, targetIndex);
        }
        index++;
      }
    }

    return SortingResult(sortedValues: arr, steps: steps);
  }

  static final algorithmComplexity = AlgorithmComplexity(
    name: StringsManager.bucketSort,
    bestTimeComplexity: ONotationComplexity.nPlusK,
    averageTimeComplexity: ONotationComplexity.nPlusK,
    worstTimeComplexity: ONotationComplexity.n2,
    spaceComplexity: ONotationComplexity.n,
    stable: true,
  );

  @override
  AlgorithmComplexity get algoComplexity => algorithmComplexity;

  @override
  String get algorithmDescription => StringsManager.bucketSortDescription;

  @override
  List<String> get codeSnippet => const [
        'void main() {', // 0
        '  List<int> arr = [64, 34, 25, 12, 22, 11, 90];', // 1
        '  int n = arr.length;', // 2
        '  int maxVal = arr.reduce((a, b) => a > b ? a : b);', // 3
        '  int minVal = arr.reduce((a, b) => a < b ? a : b);', // 4
        '  double bucketRange = (maxVal - minVal + 1) / n;', // 5
        '  List<List<int>> buckets = List.generate(n, (_) => []);', // 6
        '  for (int value in arr) {', // 7
        '    int bucketIndex = ((value - minVal) / bucketRange).floor();', // 8
        '    if (bucketIndex >= n) bucketIndex = n - 1;', // 9
        '    buckets[bucketIndex].add(value);', // 10
        '  }', // 11
        '  for (var bucket in buckets) {', // 12
        '    for (int i = 1; i < bucket.length; i++) {', // 13
        '      int key = bucket[i];', // 14
        '      int j = i - 1;', // 15
        '      while (j >= 0 && bucket[j] > key) {', // 16
        '        bucket[j + 1] = bucket[j];', // 17
        '        j--;', // 18
        '      }', // 19
        '      bucket[j + 1] = key;', // 20
        '    }', // 21
        '  }', // 22
        '  int index = 0;', // 23
        '  for (var bucket in buckets) {', // 24
        '    for (int value in bucket) {', // 25
        '      arr[index++] = value;', // 26
        '    }', // 27
        '  }', // 28
        '}', // 29
      ];

  @override
  int codeLineForStep(SortingStep step) => switch (step.action) {
        SortingStatus.compared => 16, // bucket[j] > key
        SortingStatus.swapping => 17, // bucket[j + 1] = bucket[j]
        SortingStatus.none => 15, // j--
        _ => -1,
      };
}
