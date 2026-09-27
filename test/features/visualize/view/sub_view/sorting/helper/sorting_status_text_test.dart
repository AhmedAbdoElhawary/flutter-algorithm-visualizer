import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final list = [SortableItem(id: 0, value: 17), SortableItem(id: 1, value: 9), SortableItem(id: 2, value: 4)];

  String text(SortStep? step, {bool isDone = false}) => buildStatusText(step: step, list: list, isDone: isDone);

  test('done wins over any step', () {
    const step = SortStep(kind: StepKind.compare, a: 0, b: 1, marks: []);

    expect(text(step, isDone: true), StringsManager.arrayFullySorted);
  });

  test('before the first step', () {
    expect(text(null), StringsManager.initialArrayReadyToSort);
  });

  test('compare names both positions and values', () {
    const step = SortStep(kind: StepKind.compare, a: 0, b: 1, marks: []);

    expect(text(step), '${StringsManager.compare} arr[0]=17 ↔ arr[1]=9');
  });

  test('swap names both positions', () {
    const step = SortStep(kind: StepKind.swap, a: 1, b: 2, marks: []);

    expect(text(step), '4 > 9: ${StringsManager.swapPositions} 1 ↔ 2');
  });

  test('write says which run the value came from', () {
    const fromLeft = SortStep(
      kind: StepKind.write,
      a: 2,
      b: -1,
      source: 2,
      marks: [RoleMark(role: SortRole.leftRun, start: 0, end: 1)],
    );
    const fromRight = SortStep(
      kind: StepKind.write,
      a: 2,
      b: -1,
      source: 2,
      marks: [RoleMark(role: SortRole.rightRun, start: 2, end: 2)],
    );

    expect(
      text(fromLeft),
      '${StringsManager.roleWrite} 4 ${StringsManager.fromRun} ${StringsManager.roleLeftRun} '
      '${StringsManager.intoPosition} 2',
    );
    expect(
      text(fromRight),
      '${StringsManager.roleWrite} 4 ${StringsManager.fromRun} ${StringsManager.roleRightRun} '
      '${StringsManager.intoPosition} 2',
    );
  });

  test('a minimum, held value, or pivot adds a first line with its value', () {
    const compare = '${StringsManager.compare} arr[0]=17 ↔ arr[1]=9';
    for (final (role, label) in [
      (SortRole.minimum, StringsManager.minPrefix),
      (SortRole.heldValue, StringsManager.heldPrefix),
      (SortRole.pivot, StringsManager.pivotPrefix),
    ]) {
      final step = SortStep(kind: StepKind.compare, a: 0, b: 1, marks: [RoleMark.single(role, 2)]);

      expect(text(step), '$label: 4\n$compare', reason: role.name);
    }
  });

  test('other roles add no first line', () {
    const step = SortStep(
      kind: StepKind.compare,
      a: 0,
      b: 1,
      marks: [RoleMark(role: SortRole.sorted, start: 2, end: 2)],
    );

    expect(text(step), '${StringsManager.compare} arr[0]=17 ↔ arr[1]=9');
  });

  test('every word goes through the translator, the numbers do not', () {
    String tr(String source) => '<$source>';
    const step = SortStep(
      kind: StepKind.compare,
      a: 0,
      b: 1,
      marks: [RoleMark(role: SortRole.pivot, start: 2, end: 2)],
    );

    expect(
      buildStatusText(step: step, list: list, isDone: false, tr: tr),
      '<${StringsManager.pivotPrefix}>: 4\n<${StringsManager.compare}> arr[0]=17 ↔ arr[1]=9',
    );
    expect(buildStatusText(step: null, list: list, isDone: true, tr: tr), '<${StringsManager.arrayFullySorted}>');
  });
}
