import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RoleMark', () {
    test('single covers one position', () {
      expect(RoleMark.single(SortRole.pivot, 3), const RoleMark(role: SortRole.pivot, start: 3, end: 3));
    });

    test('equal marks are equal and hash the same', () {
      const a = RoleMark(role: SortRole.sorted, start: 1, end: 4);
      const b = RoleMark(role: SortRole.sorted, start: 1, end: 4);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(const RoleMark(role: SortRole.sorted, start: 1, end: 5)));
      expect(a, isNot(const RoleMark(role: SortRole.leftRun, start: 1, end: 4)));
    });
  });

  group('SortStep', () {
    const marks = [RoleMark(role: SortRole.compare, start: 0, end: 0)];
    const step = SortStep(kind: StepKind.write, a: 0, b: -1, source: 2, marks: marks);

    test('equal steps are equal and hash the same', () {
      const copy = SortStep(
        kind: StepKind.write,
        a: 0,
        b: -1,
        source: 2,
        marks: [RoleMark(role: SortRole.compare, start: 0, end: 0)],
      );

      expect(step, copy);
      expect(step.hashCode, copy.hashCode);
    });

    test('any different field makes steps different', () {
      expect(step, isNot(const SortStep(kind: StepKind.swap, a: 0, b: -1, source: 2, marks: marks)));
      expect(step, isNot(const SortStep(kind: StepKind.write, a: 1, b: -1, source: 2, marks: marks)));
      expect(step, isNot(const SortStep(kind: StepKind.write, a: 0, b: 1, source: 2, marks: marks)));
      expect(step, isNot(const SortStep(kind: StepKind.write, a: 0, b: -1, source: 3, marks: marks)));
      expect(step, isNot(const SortStep(kind: StepKind.write, a: 0, b: -1, source: 2, marks: [])));
      expect(
        step,
        isNot(
          const SortStep(
            kind: StepKind.write,
            a: 0,
            b: -1,
            source: 2,
            marks: [RoleMark(role: SortRole.compare, start: 1, end: 1)],
          ),
        ),
      );
      expect(step, isNot('a step'));
    });
  });

  group('RoleContext', () {
    test('emit adds the operation as a mark on the positions it touches', () {
      final context = RoleContext({SortRole.compare, SortRole.swap, SortRole.write})
        ..emit(StepKind.compare, 0, 1)
        ..emit(StepKind.swap, 0, 1)
        ..emit(StepKind.write, 2, -1, 4);

      expect(context.steps, const [
        SortStep(
          kind: StepKind.compare,
          a: 0,
          b: 1,
          marks: [
            RoleMark(role: SortRole.compare, start: 0, end: 0),
            RoleMark(role: SortRole.compare, start: 1, end: 1),
          ],
        ),
        SortStep(
          kind: StepKind.swap,
          a: 0,
          b: 1,
          marks: [
            RoleMark(role: SortRole.swap, start: 0, end: 0),
            RoleMark(role: SortRole.swap, start: 1, end: 1),
          ],
        ),
        SortStep(
          kind: StepKind.write,
          a: 2,
          b: -1,
          source: 4,
          marks: [RoleMark(role: SortRole.write, start: 2, end: 2)],
        ),
      ]);
    });

    test('held roles stay on every step until released', () {
      final context = RoleContext({SortRole.compare, SortRole.pivot})
        ..hold(SortRole.pivot, 4)
        ..emit(StepKind.compare, 0, 1)
        ..hold(SortRole.pivot, 2, 3)
        ..emit(StepKind.compare, 1, 2)
        ..release(SortRole.pivot)
        ..emit(StepKind.compare, 2, 3);

      expect(context.steps.map((step) => step.marks.where((m) => m.role == SortRole.pivot)).toList(), [
        [const RoleMark(role: SortRole.pivot, start: 4, end: 4)],
        [const RoleMark(role: SortRole.pivot, start: 2, end: 3)],
        <RoleMark>[],
      ]);
    });

    test('a step with a role the algorithm did not declare is dropped', () {
      final context = RoleContext({SortRole.compare})
        ..hold(SortRole.pivot, 0)
        ..emit(StepKind.compare, 0, 1);

      expect(context.steps, isEmpty);
    });

    test('the same step twice in a row is kept once', () {
      final context = RoleContext({SortRole.compare})
        ..emit(StepKind.compare, 0, 1)
        ..emit(StepKind.compare, 0, 1)
        ..emit(StepKind.compare, 1, 2)
        ..emit(StepKind.compare, 0, 1);

      expect(context.steps.map((step) => (step.a, step.b)), [(0, 1), (1, 2), (0, 1)]);
    });

    test('steps cannot be changed from outside', () {
      final context = RoleContext({SortRole.compare})..emit(StepKind.compare, 0, 1);

      expect(() => context.steps.clear(), throwsUnsupportedError);
    });
  });
}
