part of '../view_model/sorting_notifier.dart';

/// a unique [id] for each item, but [value] can be repeated
class SortableItem {
  final int id;
  final int value;
  final SortingStatus sortedStatus;
  SortableItem({
    required this.id,
    required this.value,
    this.sortedStatus = SortingStatus.none,
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
      case SortingStatus.allSorted:
        return SortingNotifier.doneSortingColor;
      case SortingStatus.swapping:
        return SortingNotifier.swappingColor;
      case SortingStatus.compared:
        return SortingNotifier.comparedColor;
      default:
        return SortingNotifier.itemColor;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SortableItem &&
        other.id == id &&
        other.value == value &&
        other.sortedStatus.name == sortedStatus.name;
  }

  @override
  int get hashCode => id.hashCode ^ value.hashCode ^ sortedStatus.name.hashCode;
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SortingStep &&
        other.index1 == index1 &&
        other.index2 == index2 &&
        other.action.name == action.name;
  }

  @override
  int get hashCode => index1.hashCode ^ index2.hashCode ^ action.name.hashCode;

  static SortingStep noneStep() => SortingStep(index1: -1, index2: -2, action: SortingStatus.none);
}

class SortingResult {
  final List<SortingStep> steps;
  final List<int> sortedValues;

  SortingResult({required this.steps, required this.sortedValues});
}
