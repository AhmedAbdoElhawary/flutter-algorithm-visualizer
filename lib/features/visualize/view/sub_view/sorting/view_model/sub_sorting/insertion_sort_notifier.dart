import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:collection/collection.dart';

class InsertionSortNotifier extends SortingNotifier {
  @override
  Set<SortRole> get roles => const {SortRole.sorted, SortRole.heldValue, SortRole.compare, SortRole.swap};

  @override
  SortingResult buildSorting(List<int> values) {
    final arr = List<int>.from(values);
    final ctx = RoleContext(roles);

    // `sorted` is never marked mid-run here: the built prefix looks settled
    // but a later insertion can still shift it rightward, so it is not
    // actually final — only the completion sweep paints green (FR request:
    // green means "will never move again", never a guess).
    for (int i = 1; i < arr.length; i++) {
      ctx.hold(SortRole.heldValue, i);

      for (int j = i; j > 0; j--) {
        ctx.emit(StepKind.compare, j, j - 1);

        if (arr[j] < arr[j - 1]) {
          arr.swap(j, j - 1);
          ctx.hold(SortRole.heldValue, j - 1);
          ctx.emit(StepKind.swap, j, j - 1);
        } else {
          break;
        }
      }

      ctx.release(SortRole.heldValue);
    }

    return SortingResult(sortedValues: arr, steps: ctx.steps);
  }

  static final algorithmComplexity = AlgorithmComplexity(
    name: StringsManager.insertionSort,
    bestTimeComplexity: ONotationComplexity.n,
    averageTimeComplexity: ONotationComplexity.n2,
    worstTimeComplexity: ONotationComplexity.n2,
    spaceComplexity: ONotationComplexity.constant,
    stable: true,
  );

  @override
  AlgorithmComplexity get algoComplexity => algorithmComplexity;

  @override
  String get algorithmDescription => StringsManager.insertionSortDescription;
  @override
  List<String> get codeSnippet => const [
        'void main() {', // 0
        '  List<int> arr = [64, 34, 25, 12, 22, 11, 90];', // 1
        '  for (int i = 1; i < arr.length; i++) {', // 2
        '    int j = i;', // 3
        '    while (j > 0 && arr[j] < arr[j - 1]) {', // 4
        '      int temp = arr[j];', // 5
        '      arr[j] = arr[j - 1];', // 6
        '      arr[j - 1] = temp;', // 7
        '      j--;', // 8
        '    }', // 9
        '  }', // 10
        '}', // 11
      ];

  @override
  int codeLineForStep(SortStep step) => switch (step.kind) {
        StepKind.compare => 4, // arr[j] < arr[j - 1]
        StepKind.swap => 6, // arr[j] = arr[j - 1]
        StepKind.write => -1, // insertion sort never writes
      };
}
