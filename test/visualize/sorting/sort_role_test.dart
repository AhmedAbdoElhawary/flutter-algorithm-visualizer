import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('roleColor (C1)', () {
    test('is defined for every SortRole value', () {
      for (final role in SortRole.values) {
        expect(sortingRoleColor(role), isA<ThemeEnum>());
      }
    });

    test('barAnchor preimage is exactly {minimum, heldValue, pivot, rightRun} (C1.4)', () {
      final preimage = SortRole.values.where((r) => sortingRoleColor(r) == ThemeEnum.dataMedium).toSet();

      expect(preimage, {SortRole.minimum, SortRole.heldValue, SortRole.pivot, SortRole.rightRun});
    });

    test('barTarget preimage is exactly {target, boundary, leftRun} (C1.4)', () {
      final preimage = SortRole.values.where((r) => sortingRoleColor(r) == ThemeEnum.dataTarget).toSet();

      expect(preimage, {SortRole.target, SortRole.boundary, SortRole.leftRun});
    });

    test('swap and write share barSwap (C1.3)', () {
      expect(sortingRoleColor(SortRole.swap), ThemeEnum.dataHard);
      expect(sortingRoleColor(SortRole.write), ThemeEnum.dataHard);
    });
  });

  group('roleLabel (C2)', () {
    test('no two SortRole values map to the same label, except idle which is never called', () {
      final labels = <String>{};
      for (final role in SortRole.values) {
        if (role == SortRole.idle) continue;
        final label = roleLabel(role);
        expect(labels.contains(label), isFalse, reason: '$role duplicates label "$label"');
        labels.add(label);
      }
    });
  });

  group('kRolePriority (VR-4)', () {
    test('contains every SortRole exactly once', () {
      expect(kRolePriority.toSet(), SortRole.values.toSet());
      expect(kRolePriority.length, SortRole.values.length);
    });
  });

  group('resolve (C3 collision table)', () {
    test('{compare, minimum} -> minimum (held anchors outrank compare)', () {
      expect(resolve({SortRole.compare, SortRole.minimum}), SortRole.minimum);
    });

    test('{swap, pivot} -> swap', () {
      expect(resolve({SortRole.swap, SortRole.pivot}), SortRole.swap);
    });

    test('{compare, pivot} -> pivot (held anchors outrank compare)', () {
      expect(resolve({SortRole.compare, SortRole.pivot}), SortRole.pivot);
    });

    test('{write, leftRun} -> write', () {
      expect(resolve({SortRole.write, SortRole.leftRun}), SortRole.write);
    });

    test('{leftRun, sorted} -> leftRun', () {
      expect(resolve({SortRole.leftRun, SortRole.sorted}), SortRole.leftRun);
    });

    test('{boundary, minimum} -> minimum', () {
      expect(resolve({SortRole.boundary, SortRole.minimum}), SortRole.minimum);
    });

    test('{sorted} -> sorted', () {
      expect(resolve({SortRole.sorted}), SortRole.sorted);
    });

    test('{} -> idle', () {
      expect(resolve({}), SortRole.idle);
    });
  });
}
