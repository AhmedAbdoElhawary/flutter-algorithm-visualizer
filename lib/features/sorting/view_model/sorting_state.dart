part of 'sorting_notifier.dart';

class SortingNotifierState {
  final List<SortableItem> list;
  final Map<int, Offset> positions;

  SortingNotifierState({required this.list, this.positions = const {}});

  SortingNotifierState copyWith({
    List<SortableItem>? list,
    Map<int, Offset>? positions,
  }) {
    return SortingNotifierState(
      list: list ?? this.list,
      positions: positions ?? this.positions,
    );
  }
}
