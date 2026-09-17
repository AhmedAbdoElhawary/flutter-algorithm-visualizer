import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';

class MergeSortNotifier extends SortingNotifier {
  @override
  Set<SortRole> get roles =>
      const {SortRole.sorted, SortRole.leftRun, SortRole.rightRun, SortRole.compare, SortRole.write};

  @override
  SortingResult buildSorting(List<int> values) {
    final arr = List<int>.from(values);

    if (arr.isEmpty || arr.length == 1) {
      return SortingResult(sortedValues: arr, steps: const []);
    }

    final ctx = RoleContext(roles);

    // Classic auxiliary-buffer merge (FR-035, FR-036): every placement is a
    // `write` into the destination; no element is ever swapped in place, so
    // this is no longer the quadratic adjacent-swap merge.
    void merge(int left, int mid, int right) {
      int i = left;
      int j = mid + 1;
      int k = left;
      final merged = <int>[];

      ctx.hold(SortRole.leftRun, i, mid);
      ctx.hold(SortRole.rightRun, j, right);

      while (i <= mid && j <= right) {
        ctx.emit(StepKind.compare, i, j);

        if (arr[i] <= arr[j]) {
          merged.add(arr[i]);
          i++;
          ctx.emit(StepKind.write, k, -1, k);
          if (i > mid) {
            ctx.release(SortRole.leftRun);
          } else {
            ctx.hold(SortRole.leftRun, i, mid);
          }
        } else {
          final remainingLeft = mid - i + 1;
          final currentIndex = k + remainingLeft;
          merged.add(arr[j]);
          j++;
          ctx.emit(StepKind.write, k, -1, currentIndex);
          if (j > right) {
            ctx.release(SortRole.rightRun);
          } else {
            ctx.hold(SortRole.rightRun, j, right);
          }
        }
        k++;
      }

      while (i <= mid) {
        merged.add(arr[i]);
        i++;
        ctx.emit(StepKind.write, k, -1, k);
        k++;
        if (i > mid) {
          ctx.release(SortRole.leftRun);
        } else {
          ctx.hold(SortRole.leftRun, i, mid);
        }
      }

      while (j <= right) {
        final remainingLeft = mid - i + 1;
        final currentIndex = k + remainingLeft;
        merged.add(arr[j]);
        j++;
        ctx.emit(StepKind.write, k, -1, currentIndex);
        k++;
        if (j > right) {
          ctx.release(SortRole.rightRun);
        } else {
          ctx.hold(SortRole.rightRun, j, right);
        }
      }

      for (int x = 0; x < merged.length; x++) {
        arr[left + x] = merged[x];
      }
    }

    void mergeSort(int left, int right) {
      if (left >= right) return;

      final midIndex = (left + right) ~/ 2;

      mergeSort(left, midIndex);
      mergeSort(midIndex + 1, right);

      merge(left, midIndex, right);
    }

    mergeSort(0, arr.length - 1);

    return SortingResult(sortedValues: arr, steps: ctx.steps);
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
        '  if (left >= right) return;', // 5
        '  int mid = (left + right) ~/ 2;', // 6
        '  mergeSort(arr, left, mid);', // 7
        '  mergeSort(arr, mid + 1, right);', // 8
        '  merge(arr, left, mid, right);', // 9
        '}', // 10
        'void merge(List<int> arr, int left, int mid, int right) {', // 11
        '  int i = left, j = mid + 1, k = left;', // 12
        '  final merged = <int>[];', // 13
        '  while (i <= mid && j <= right) {', // 14
        '    if (arr[i] <= arr[j]) {', // 15
        '      merged.add(arr[i++]);', // 16
        '    } else {', // 17
        '      merged.add(arr[j++]);', // 18
        '    }', // 19
        '  }', // 20
        '  while (i <= mid) merged.add(arr[i++]);', // 21
        '  while (j <= right) merged.add(arr[j++]);', // 22
        '  for (int x = 0; x < merged.length; x++) {', // 23
        '    arr[left + x] = merged[x];', // 24
        '  }', // 25
        '}', // 26
      ];

  @override
  int codeLineForStep(SortStep step) => switch (step.kind) {
        StepKind.compare => 15, // arr[i] <= arr[j]
        StepKind.write => 24, // arr[left + x] = merged[x]
        StepKind.swap => -1, // merge sort never swaps
      };
}
