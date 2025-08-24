part of 'comparison_sort_notifier.dart';

class ComparisonSortingNotifierState {
  final List<SortingAlgorithm> selectedAlgorithms;
  final SortingEnum operationStatus;

  ComparisonSortingNotifierState({
    required this.selectedAlgorithms,
    this.operationStatus = SortingEnum.none,
  });

  ComparisonSortingNotifierState copyWith({
    SortingEnum? operationStatus,
    List<SortingAlgorithm>? selectedAlgorithms,
  }) {
    return ComparisonSortingNotifierState(
      operationStatus: operationStatus ?? this.operationStatus,
      selectedAlgorithms: selectedAlgorithms ?? this.selectedAlgorithms,
    );
  }
}
