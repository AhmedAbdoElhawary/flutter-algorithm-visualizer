import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:collection/collection.dart';

class SelectionSortNotifier extends SortingNotifier {
  @override
  Set<SortRole> get roles =>
      const {SortRole.sorted, SortRole.minimum, SortRole.compare, SortRole.target, SortRole.swap};

  @override
  Map<SortRole, String> get pointerHints => const {
        SortRole.compare: StringsManager.pointerHintJ,
        SortRole.target: StringsManager.pointerHintI,
      };

  @override
  SortingResult buildSorting(List<int> values) {
    final arr = List<int>.from(values);
    final ctx = RoleContext(roles);

    // `sorted` is never marked mid-run here — only the final completion
    // sweep paints green, once every bar is truly done moving.
    for (int i = 0; i < arr.length - 1; i++) {
      int minIndex = i;
      ctx.hold(SortRole.target, i);
      ctx.hold(SortRole.minimum, minIndex);

      for (int j = i + 1; j < arr.length; j++) {
        ctx.emit(StepKind.compare, minIndex, j);

        if (arr[j] < arr[minIndex]) {
          minIndex = j;
          ctx.hold(SortRole.minimum, minIndex);
        }
      }

      if (minIndex != i) {
        arr.swap(minIndex, i);
        ctx.emit(StepKind.swap, i, minIndex);
      }

      ctx.release(SortRole.minimum);
      ctx.release(SortRole.target);
    }

    return SortingResult(sortedValues: arr, steps: ctx.steps);
  }

  static final algorithmComplexity = AlgorithmComplexity(
    name: StringsManager.selectionSort,
    bestTimeComplexity: ONotationComplexity.n2,
    averageTimeComplexity: ONotationComplexity.n2,
    worstTimeComplexity: ONotationComplexity.n2,
    spaceComplexity: ONotationComplexity.constant,
    stable: true,
  );

  @override
  AlgorithmComplexity get algoComplexity => algorithmComplexity;

  @override
  String get algorithmDescription => StringsManager.selectionSortDescription;
  @override
  List<String> get codeSnippet => const [
        'void main() {', // 0
        '  List<int> arr = [64, 34, 25, 12, 22, 11, 90];', // 1
        '  for (int i = 0; i < arr.length - 1; i++) {', // 2
        '    int minIndex = i;', // 3
        '    for (int j = i + 1; j < arr.length; j++) {', // 4
        '      if (arr[j] < arr[minIndex]) {', // 5
        '        minIndex = j;', // 6
        '      }', // 7
        '    }', // 8
        '    if (minIndex != i) {', // 9
        '      int temp = arr[i];', // 10
        '      arr[i] = arr[minIndex];', // 11
        '      arr[minIndex] = temp;', // 12
        '    }', // 13
        '  }', // 14
        '}', // 15
      ];

  @override
  int codeLineForStep(SortStep step) => switch (step.kind) {
        StepKind.compare => 5, // arr[j] < arr[minIndex]
        StepKind.swap => 11, // arr[i] = arr[minIndex]
        StepKind.write => -1, // selection sort never writes
      };
}
