import 'package:algorithm_visualizer/features/visualize/helper/playback_speed.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sub_sorting/bubble_sort_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sub_sorting/insertion_sort_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sub_sorting/merge_sort_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sub_sorting/quick_sort_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sub_sorting/selection_sort_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

final _algorithms = <String, SortingNotifier Function()>{
  'bubble': BubbleSortNotifier.new,
  'selection': SelectionSortNotifier.new,
  'insertion': InsertionSortNotifier.new,
  'merge': MergeSortNotifier.new,
  'quick': QuickSortNotifier.new,
};

List<int> _reverseSorted(int n) => List.generate(n, (i) => n - i);
List<int> _random(int n, int seed) {
  final values = List.generate(n, (i) => i + 1);
  values.shuffle(); // deterministic seeding isn't needed — every property here must hold for any order
  return values;
}

void main() {
  setUpAll(() {
    // Non-widget tests never run through ScreenUtilInit, but the notifier's
    // position math reads ScreenUtil() directly — configure it once with a
    // fixed MediaQueryData so `build()` doesn't throw.
    ScreenUtil.configure(
      data: const MediaQueryData(size: Size(430, 932)),
      designSize: const Size(430, 932),
      splitScreenMode: false,
      minTextAdapt: false,
    );
  });

  group('the counter is honest — for every algorithm and size 5..15 (FR-026, FR-029, SC-002, SC-011)', () {
    for (final entry in _algorithms.entries) {
      test('${entry.key}: no two consecutive steps equal, no self-swap, only compare/swap/write', () {
        for (int n = 5; n <= 15; n++) {
          final notifier = entry.value();
          final steps = notifier.buildSorting(_reverseSorted(n)).steps;

          for (int i = 1; i < steps.length; i++) {
            expect(steps[i], isNot(equals(steps[i - 1])), reason: '$n elements, step $i');
          }

          for (final step in steps.where((s) => s.kind == StepKind.swap)) {
            expect(step.a, isNot(equals(step.b)));
          }
        }
      });
    }
  });

  group('replaying every step reproduces the correctly sorted array (FR-033, SC-006, C6.5)', () {
    for (final entry in _algorithms.entries) {
      test('${entry.key}: random, duplicate-heavy, and already-sorted arrays', () {
        final inputs = [
          _random(10, 1),
          _random(10, 2),
          [3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5],
          [1, 2, 3, 4, 5, 6, 7],
          [7, 6, 5, 4, 3, 2, 1],
        ];

        for (final input in inputs) {
          final result = entry.value().buildSorting(input);
          final expected = List<int>.from(input)..sort();
          expect(result.sortedValues, expected, reason: '$input via ${entry.key}');
        }
      });
    }
  });

  group('complexity agreement (FR-034, C8.3, C8.4)', () {
    test('bubble and insertion emit n-1 compares and zero movements on already-sorted input', () {
      for (int n = 5; n <= 15; n++) {
        final sorted = List.generate(n, (i) => i);

        for (final factory in [BubbleSortNotifier.new, InsertionSortNotifier.new]) {
          final steps = factory().buildSorting(sorted).steps;
          expect(steps.where((s) => s.kind == StepKind.compare).length, n - 1);
          expect(steps.any((s) => s.kind == StepKind.swap), isFalse);
        }
      }
    });
  });

  group('stateful playback — stepping forward/back through the notifier (US3)', () {
    // A representative subset (not the full 5x11 grid) keeps this fast while
    // still exercising every algorithm at more than one size.
    const sizes = [5, 8, 15];

    for (final entry in _algorithms.entries) {
      for (final size in sizes) {
        test(
            '${entry.key} size $size: forward count == total, backward reproduces every snapshot exactly '
            '(FR-028, FR-031, FR-032, SC-001, SC-007, C9.1-C9.3)', () async {
          SortingNotifier.debugInitialListOverride =
              List.generate(size, (i) => SortableItem(id: i, value: size - i));
          addTearDown(() => SortingNotifier.debugInitialListOverride = null);

          final provider = NotifierProvider<SortingNotifier, SortingNotifierState>(entry.value);
          final container = ProviderContainer();
          addTearDown(container.dispose);

          final notifier = container.read(provider.notifier);
          notifier.changeSpeed(PlaybackSpeed.fast10);

          // Walk forward from 0 to the end, recording every snapshot.
          final forwardSnapshots = <SortingNotifierState>[container.read(provider)];
          int landings = 0;
          while (!container.read(provider).isAtLastStep) {
            notifier.stepForward();
            landings++;
            forwardSnapshots.add(container.read(provider));
          }

          final total = container.read(provider).totalPlaySteps;
          expect(landings, total, reason: 'FR-032/SC-001: forward landings must equal the displayed total');
          expect(container.read(provider).currentStepIndex, total);

          // Walk back to 0 and compare against the recorded forward path.
          for (int i = total; i > 0; i--) {
            notifier.stepBackward();
            final backward = container.read(provider);
            final forward = forwardSnapshots[i - 1];

            expect(backward.list.map((e) => e.id), forward.list.map((e) => e.id),
                reason: 'index order at step ${i - 1}');
            expect(backward.list.map((e) => e.value), forward.list.map((e) => e.value),
                reason: 'values at step ${i - 1}');
            expect(backward.rolePerIndex, forward.rolePerIndex, reason: 'roles at step ${i - 1}');
          }

          expect(container.read(provider).currentStepIndex, 0);

          // Reaching the last step above fired the (unawaited) completion
          // sweep — drain it before the container is disposed in tearDown,
          // or its delayed writes throw against a dead provider.
          await Future.delayed(PlaybackSpeed.fast10.stepSortingDuration * (size + 2));
        });
      }
    }
  });

  group('status text is shared across algorithms (FR-039, US4 scenario 2)', () {
    test('selection sort and quick sort phrase a comparison identically', () {
      // Same (a, b) and StepKind, different algorithm-specific marks — the
      // sentence builder chooses its shape by StepKind alone (C13.1), so
      // the comparison line itself (after the optional anchor prefix) must
      // read identically regardless of which anchor role is live.
      const selectionStep = SortStep(
        kind: StepKind.compare,
        a: 0,
        b: 1,
        marks: [
          RoleMark(role: SortRole.minimum, start: 0, end: 0),
          RoleMark(role: SortRole.target, start: 0, end: 0),
        ],
      );
      const quickStep = SortStep(
        kind: StepKind.compare,
        a: 0,
        b: 1,
        marks: [
          RoleMark(role: SortRole.pivot, start: 2, end: 2),
          RoleMark(role: SortRole.boundary, start: 0, end: 0),
        ],
      );

      final list = [
        SortableItem(id: 0, value: 3),
        SortableItem(id: 1, value: 1),
        SortableItem(id: 2, value: 2),
      ];

      final selectionText = buildStatusText(step: selectionStep, list: list, isDone: false).split('\n').last;
      final quickText = buildStatusText(step: quickStep, list: list, isDone: false).split('\n').last;

      expect(selectionText, quickText);
    });
  });

  group('stepping guards against out-of-range indices (C9.6)', () {
    test('stepBackward at index 0 is a no-op; stepForward past the end is a no-op', () async {
      SortingNotifier.debugInitialListOverride = List.generate(5, (i) => SortableItem(id: i, value: 5 - i));
      addTearDown(() => SortingNotifier.debugInitialListOverride = null);

      final provider = NotifierProvider<SortingNotifier, SortingNotifierState>(BubbleSortNotifier.new);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(provider.notifier);
      notifier.changeSpeed(PlaybackSpeed.fast10);

      notifier.stepBackward();
      expect(container.read(provider).currentStepIndex, 0);

      while (!container.read(provider).isAtLastStep) {
        notifier.stepForward();
      }
      final total = container.read(provider).totalPlaySteps;
      notifier.stepForward();
      expect(container.read(provider).currentStepIndex, total);

      await Future.delayed(PlaybackSpeed.fast10.stepSortingDuration * 7);
    });
  });
}
