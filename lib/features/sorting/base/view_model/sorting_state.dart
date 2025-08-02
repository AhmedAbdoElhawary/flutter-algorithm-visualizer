part of 'sorting_notifier.dart';

class SortingNotifierState {
  final List<SortableItem> list;
  final Map<int, Offset> positions;
  final Duration swipeDuration;
  final int size;
  SortingNotifierState({
    this.size = SortingNotifier._defaultSize,
    this.swipeDuration = SortingNotifier._defaultSpeedDuration,
    required this.list,
    this.positions = const {},
  });

  SortingNotifierState copyWith({
    int? size,
    Duration? swipeDuration,
    List<SortableItem>? list,
    Map<int, Offset>? positions,
    List<SortingAlgorithm>? selectedAlgorithms,
  }) {
    return SortingNotifierState(
      size: size ?? this.size,
      swipeDuration: swipeDuration ?? this.swipeDuration,
      list: list ?? this.list,
      positions: positions ?? this.positions,
    );
  }
}
