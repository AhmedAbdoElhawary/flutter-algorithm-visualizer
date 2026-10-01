import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SortableItem', () {
    test('copyWith changes only what is given', () {
      final item = SortableItem(id: 1, value: 5);

      expect(item.copyWith(value: 9), SortableItem(id: 1, value: 9));
      expect(item.copyWith(id: 2), SortableItem(id: 2, value: 5));
      expect(item.copyWith(), item);
    });

    test('items with the same id and value are equal and hash the same', () {
      expect(SortableItem(id: 1, value: 5), SortableItem(id: 1, value: 5));
      expect(SortableItem(id: 1, value: 5).hashCode, SortableItem(id: 1, value: 5).hashCode);
    });

    test('the same value with another id is a different item', () {
      expect(SortableItem(id: 1, value: 5), isNot(SortableItem(id: 2, value: 5)));
    });
  });

  group('SortingResult', () {
    const steps = [SortStep(kind: StepKind.compare, a: 0, b: 1, marks: [])];

    test('results with the same steps and values are equal and hash the same', () {
      final a = SortingResult(steps: [...steps], sortedValues: [1, 2]);
      final b = SortingResult(steps: [...steps], sortedValues: [1, 2]);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('different steps or values make results different', () {
      final result = SortingResult(steps: steps, sortedValues: [1, 2]);

      expect(result, isNot(SortingResult(steps: const [], sortedValues: [1, 2])));
      expect(result, isNot(SortingResult(steps: steps, sortedValues: [2, 1])));
    });
  });
}
