part of '../view_model/sorting_notifier.dart';

/// a unique [id] for each item, but [value] can be repeated
class SortableItem {
  final int id;
  final int value;
  SortableItem({required this.id, required this.value});

  SortableItem copyWith({int? id, int? value}) {
    return SortableItem(id: id ?? this.id, value: value ?? this.value);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SortableItem && other.id == id && other.value == value;
  }

  @override
  int get hashCode => id.hashCode ^ value.hashCode;
}

class SortingResult {
  final List<SortStep> steps;
  final List<int> sortedValues;

  SortingResult({required this.steps, required this.sortedValues});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SortingResult && other.steps == steps && other.sortedValues == sortedValues;
  }

  @override
  int get hashCode => steps.hashCode ^ sortedValues.hashCode;
}
