import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';

class SelectionSortNotifier extends SortingNotifier {
  @override
  List<SortingStep> buildSorting(List<int> values) {
    final steps = <SortingStep>[];
    final arr = List<int>.from(values);

    for (int i = 0; i < arr.length - 1; i++) {
      int minIndex = i;

      for (int j = i + 1; j < arr.length; j++) {
        steps.add(SortingStep(index1: minIndex, index2: j, action: SortingStatus.compared));

        if (arr[j] < arr[minIndex]) {
          final previousIndex = minIndex;
          // to reset action
          if (minIndex != i) {
            steps.add(SortingStep(index1: previousIndex, index2: previousIndex, action: SortingStatus.none));
          }
          minIndex = j;
        }

        steps.add(SortingStep(index1: minIndex, index2: j, action: SortingStatus.unSorted));
      }

      if (minIndex != i) {
        steps.add(SortingStep(index1: i, index2: minIndex, action: SortingStatus.swiping));

        final temp = arr[i];
        arr[i] = arr[minIndex];
        arr[minIndex] = temp;
        steps.add(SortingStep(index1: minIndex, index2: j, action: SortingStatus.swiped));
      }

      steps.add(SortingStep(index1: i, index2: i, action: SortingStatus.sorted));
    }

    steps.add(SortingStep(index1: arr.length - 1, index2: arr.length - 1, action: SortingStatus.sorted));

    return steps;
  }
}
