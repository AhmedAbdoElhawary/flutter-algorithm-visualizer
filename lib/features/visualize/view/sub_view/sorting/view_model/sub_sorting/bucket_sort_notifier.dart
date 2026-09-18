import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';

class BucketSortNotifier extends SortingNotifier {
  @override
  Set<SortRole> get roles => const {
        SortRole.sorted,
        SortRole.compare,
        SortRole.swap,
      };

  @override
  SortingResult buildSorting(List<int> values) {
    final arr = List<int>.from(values);
    if (arr.length < 2) {
      return SortingResult(sortedValues: arr, steps: const []);
    }

    final ctx = RoleContext(roles);
    final minimum = arr.reduce((a, b) => a < b ? a : b);
    final maximum = arr.reduce((a, b) => a > b ? a : b);
    final bucketCount = arr.length;
    final bucketRange = (maximum - minimum + 1) / bucketCount;
    final buckets = List.generate(bucketCount, (_) => <_BucketItem>[]);

    for (int index = 0; index < arr.length; index++) {
      int bucketIndex = ((arr[index] - minimum) / bucketRange).floor();
      if (bucketIndex >= bucketCount) bucketIndex = bucketCount - 1;
      buckets[bucketIndex].add(
        _BucketItem(value: arr[index], originalIndex: index),
      );
    }

    // Sort each bucket stably. Original indexes let the replay phase distinguish
    // equal values, which is essential when it builds visual swap steps.
    for (final bucket in buckets) {
      for (int i = 1; i < bucket.length; i++) {
        final item = bucket[i];
        int j = i - 1;

        while (j >= 0) {
          ctx.emit(
            StepKind.compare,
            item.originalIndex,
            bucket[j].originalIndex,
          );
          if (bucket[j].value <= item.value) break;
          bucket[j + 1] = bucket[j];
          j--;
        }
        bucket[j + 1] = item;
      }
    }

    final sortedItems = buckets.expand((bucket) => bucket).toList();
    final currentItems = [
      for (int index = 0; index < arr.length; index++)
        _BucketItem(value: arr[index], originalIndex: index),
    ];

    // Turn the bucket output into replayable, identity-safe swaps. Values alone
    // cannot identify a duplicate; each item keeps its original index.
    for (int index = 0; index < currentItems.length; index++) {
      final target = sortedItems[index];
      final currentIndex = currentItems.indexWhere(
        (item) => item.originalIndex == target.originalIndex,
        index,
      );
      if (currentIndex == index) continue;

      final temporary = currentItems[index];
      currentItems[index] = currentItems[currentIndex];
      currentItems[currentIndex] = temporary;
      ctx.emit(StepKind.swap, index, currentIndex);
    }

    return SortingResult(
      sortedValues: currentItems.map((item) => item.value).toList(),
      steps: ctx.steps,
    );
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
        'List<int> bucketSort(List<int> arr) {',
        '  final min = arr.reduce((a, b) => a < b ? a : b);',
        '  final max = arr.reduce((a, b) => a > b ? a : b);',
        '  final range = (max - min + 1) / arr.length;',
        '  final buckets = List.generate(arr.length, (_) => <int>[]);',
        '  for (final value in arr) {',
        '    final index = ((value - min) / range).floor();',
        '    buckets[index].add(value);',
        '  }',
        '  for (final bucket in buckets) {',
        '    bucket.sort();',
        '  }',
        '  return buckets.expand((bucket) => bucket).toList();',
        '}',
      ];

  @override
  int codeLineForStep(SortStep step) => switch (step.kind) {
        StepKind.compare => 10,
        StepKind.swap => 12,
        StepKind.write => -1,
      };
}

class _BucketItem {
  final int value;
  final int originalIndex;

  const _BucketItem({required this.value, required this.originalIndex});
}
