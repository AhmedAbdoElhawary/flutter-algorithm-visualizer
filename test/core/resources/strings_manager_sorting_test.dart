import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no two of the new sorting-feature constants hold the same user-facing text (SC-008, C14.1)', () {
    // roleCompare deliberately aliases `compare`, and pivotPrefix aliases
    // rolePivot (same constant, not a duplicate — C2.2), so both are
    // intentionally omitted here rather than counted as a second entry with
    // equal text.
    final constants = <String, String>{
      'compare': StringsManager.compare,
      'swapPositions': StringsManager.swapPositions,
      'arrayFullySorted': StringsManager.arrayFullySorted,
      'initialArrayReadyToSort': StringsManager.initialArrayReadyToSort,
      'roleSwap': StringsManager.roleSwap,
      'roleWrite': StringsManager.roleWrite,
      'roleSorted': StringsManager.roleSorted,
      'roleMinimum': StringsManager.roleMinimum,
      'roleHeldValue': StringsManager.roleHeldValue,
      'rolePivot': StringsManager.rolePivot,
      'roleRightRun': StringsManager.roleRightRun,
      'roleTarget': StringsManager.roleTarget,
      'roleBoundary': StringsManager.roleBoundary,
      'roleLeftRun': StringsManager.roleLeftRun,
      'minPrefix': StringsManager.minPrefix,
      'heldPrefix': StringsManager.heldPrefix,
      'pointerHintI': StringsManager.pointerHintI,
      'pointerHintJ': StringsManager.pointerHintJ,
      'fromRun': StringsManager.fromRun,
      'intoPosition': StringsManager.intoPosition,
    };

    final seen = <String, String>{};
    for (final entry in constants.entries) {
      final existing = seen[entry.value];
      expect(existing, isNull, reason: '"${entry.value}" is held by both $existing and ${entry.key}');
      seen[entry.value] = entry.key;
    }
  });

  test('roleCompare aliases compare rather than duplicating its text (C2.2)', () {
    expect(StringsManager.roleCompare, StringsManager.compare);
  });
}
