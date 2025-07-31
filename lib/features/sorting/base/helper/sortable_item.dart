part of '../view_model/sorting_notifier.dart';

/// a unique [id] for each item, but [value] can be repeated
class SortableItem {
  final int id;
  final int value;
  final SortingStatus sortedStatus;
  SortableItem({
    required this.id,
    required this.value,
    this.sortedStatus = SortingStatus.unSorted,
  });

  SortableItem copyWith({int? id, int? value, SortingStatus? sortedStatus}) {
    return SortableItem(
      id: id ?? this.id,
      value: value ?? this.value,
      sortedStatus: sortedStatus ?? this.sortedStatus,
    );
  }

  ThemeEnum get getColor {
    switch (sortedStatus) {
      case SortingStatus.sorted:
        return SortingNotifier.doneSortingColor;
      case SortingStatus.swapping:
        return SortingNotifier.swappingColor;
      case SortingStatus.compared:
        return SortingNotifier.comparedColor;
      default:
        return SortingNotifier.itemColor;
    }
  }
}

class SortingStep {
  final int index1;
  final int index2;
  final SortingStatus action;

  SortingStep({
    required this.index1,
    required this.index2,
    required this.action,
  });
}
