part of 'sorting_notifier.dart';

class SortingNotifierState {
  final ComparableTwoItems? comparableTwoItems;
  final List<SortableItem> list;
  final Map<int, Offset> positions;
  final List<SortingAlgorithm> selectedAlgorithms;

  SortingNotifierState({
    this.comparableTwoItems,
    required this.list,
    this.positions = const {},
    this.selectedAlgorithms = const [],
  });

  SortingNotifierState copyWith({
    ComparableTwoItems? comparableTwoItems,
    List<SortableItem>? list,
    Map<int, Offset>? positions,
    List<SortingAlgorithm>? selectedAlgorithms,
  }) {
    return SortingNotifierState(
      comparableTwoItems: comparableTwoItems ?? this.comparableTwoItems,
      list: list ?? this.list,
      positions: positions ?? this.positions,
      selectedAlgorithms: selectedAlgorithms ?? this.selectedAlgorithms,
    );
  }
}
