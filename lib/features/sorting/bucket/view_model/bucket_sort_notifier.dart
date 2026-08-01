import 'package:algorithm_visualizer/core/helpers/o_notation.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
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
          steps.add(SortingStep(index1: index, index2: targetIndex, action: SortingStatus.swapped));
        }
        index++;
      }
    }

    steps.add(SortingStep(index1: arr.length - 1, index2: arr.length - 1, action: SortingStatus.sorted));

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
  String get description => StringsManager.bucketSortDescription;

  @override
  List<String> get codeSnippet => const [
    'n = arr.length',                          // 0
    'buckets = array of n empty lists',        // 1
    'for i from 0 to n-1',                    // 2
    '  idx = floor(arr[i] × n / max)',         // 3
    '  buckets[idx].add(arr[i])',              // 4
    'for each bucket b',                       // 5
    '  insertionSort(b)',                      // 6
    '    if b[j] > b[j+1]',                   // 7
    '      swap(b[j], b[j+1])',               // 8
    'concatenate all buckets into arr',        // 9
  ];

  @override
  int codeLineForStep(SortingStep step) => switch (step.action) {
    SortingStatus.compared                              => 7,  // compare within bucket
    SortingStatus.swapping                              => 8,  // swap within bucket
    SortingStatus.swapped || SortingStatus.unSorted     => 6,  // continue bucket sort
    SortingStatus.sorted                                => 9,  // merge buckets back
    _                                                   => -1,
  };
}
