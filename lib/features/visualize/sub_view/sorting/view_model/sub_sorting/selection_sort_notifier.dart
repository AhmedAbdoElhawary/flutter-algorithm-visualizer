import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:collection/collection.dart';

class SelectionSortNotifier extends SortingNotifier {


  @override
  String statusText({
    required SortingStep? previousStep,
    required SortingStep? currentStep,
    required List<SortableItem> list,
  }) {
    final text = super.statusText(previousStep: previousStep, currentStep: currentStep, list: list);
    if (currentStep == null) return text;
    final action = currentStep.action;

    if ((action == SortingStatus.swapping || action == SortingStatus.compared)) {
      final minValue = getWrittenHeight(list[currentStep.index1].value);
      return "${StringsManager.minValue}: $minValue \n$text";
    }

    if (action == SortingStatus.temporary) {
      final minValue = getWrittenHeight(list[currentStep.index1].value);

      final previousText =
          super.statusText(previousStep: previousStep, currentStep: previousStep, list: list);
      return "${StringsManager.minValue}: $minValue \n$previousText";
    }

    if (action == SortingStatus.sorted) {
      final minValue = getWrittenHeight(list[currentStep.index1].value);
      return "arr[${currentStep.index1}] = $minValue ${StringsManager.sortedNow}";
    }

    return text;
  }

  @override
  SortingResult buildSorting(List<int> values) {
    final steps = <SortingStep>[];
    final arr = List<int>.from(values);

    for (int i = 0; i < arr.length - 1; i++) {
      int minIndex = i;
      steps.add(SortingStep(index1: minIndex, index2: minIndex, action: SortingStatus.temporary));

      for (int j = i + 1; j < arr.length; j++) {
        steps.add(SortingStep(index1: minIndex, index2: j, action: SortingStatus.compared));

        if (arr[j] < arr[minIndex]) {
          minIndex = j;
          steps.add(SortingStep(index1: minIndex, index2: minIndex, action: SortingStatus.temporary));
        }
      }

      if (minIndex != i) {
        steps.add(SortingStep(index1: i, index2: minIndex, action: SortingStatus.swapping));

        arr.swap(minIndex, i);
      }
      steps.add(SortingStep(index1: i, index2: i, action: SortingStatus.sorted));
    }

    return SortingResult(sortedValues: arr, steps: steps);
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
  int codeLineForStep(SortingStep step) => switch (step.action) {
        SortingStatus.compared => 5, // arr[j] < arr[minIndex]
        SortingStatus.swapping => 11, // arr[i] = arr[minIndex]
        SortingStatus.none => 4, // advance inner loop
        _ => -1,
      };
}
