part of 'sorting_notifier.dart';

class SortingNotifierState {
  final List<SortableItem> list;
  final Map<int, Offset> positions;
  final List<SortingAlgorithm> selectedAlgorithms;

  SortingNotifierState({required this.list, this.positions = const {}, this.selectedAlgorithms = const []});

  SortingNotifierState copyWith({
    List<SortableItem>? list,
    Map<int, Offset>? positions,
    List<SortingAlgorithm>? selectedAlgorithms,
  }) {
    return SortingNotifierState(
      list: list ?? this.list,
      positions: positions ?? this.positions,
      selectedAlgorithms: selectedAlgorithms ?? this.selectedAlgorithms,
    );
  }
}
