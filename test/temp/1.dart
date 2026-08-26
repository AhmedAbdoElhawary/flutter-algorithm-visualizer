// // bubble_sort_algorithm_test.dart
// //
// // LAYER 1 — pure algorithm correctness.
// //
// // These tests call `BubbleSortNotifier().buildSorting(values)` directly.
// // `buildSorting` never touches Riverpod's `state`, so we can instantiate
// // the Notifier class without registering it with a ProviderContainer.
// // This makes these tests fast, deterministic, and independent of Flutter
// // bindings / ScreenUtil / theming — they will run under plain `flutter test`
// // with no pumping required.
// //
// // ASSUMPTIONS (adjust if your sibling files differ):
// //   - `SortingStatus` has values: none, compared, swapping, allSorted.
// //   - `SortingResult` exposes `.sortedValues` (List<int>) and `.steps`
// //     (List<SortingStep>).
// //   - `SortingStep` exposes `.index1`, `.index2`, `.action`.
// //   - `BubbleSortNotifier` can be constructed with a no-arg constructor
// //     without calling `build()` first (true for a plain Riverpod
// //     `Notifier` as long as you never touch `.state`).
//
// import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
// import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sorting_notifier.dart';
// import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sub_sorting/bubble_sort_notifier.dart';
// import 'package:flutter_test/flutter_test.dart';
//
// void main() {
//   late BubbleSortNotifier notifier;
//
//   setUp(() {
//     notifier = BubbleSortNotifier();
//   });
//
//   group('BubbleSortNotifier.buildSorting — correctness', () {
//     test('empty list sorts to empty list with no steps', () {
//       final result = notifier.buildSorting([]);
//       expect(result.sortedValues, isEmpty);
//       expect(result.steps, isEmpty);
//     });
//
//     test('single-element list sorts to itself with no steps', () {
//       final result = notifier.buildSorting([42]);
//       expect(result.sortedValues, equals([42]));
//       expect(result.steps, isEmpty);
//     });
//
//     test('already-sorted list produces only comparisons, no swaps, and exits early', () {
//       final input = [1, 2, 3, 4, 5];
//       final result = notifier.buildSorting(input);
//
//       expect(result.sortedValues, equals([1, 2, 3, 4, 5]));
//       // Early-exit optimization: only the first pass runs (n-1 comparisons),
//       // and since nothing is out of order, there must be zero swaps.
//       expect(result.steps.length, 4);
//       expect(result.steps.every((s) => s.action == SortingStatus.compared), isTrue);
//     });
//
//     test('reverse-sorted list produces the expected comparison/swap counts', () {
//       // Worked out by hand (see PR description / test rationale):
//       // n=5 reverse order -> passes of length 4,3,2,1 comparisons,
//       // and every comparison in this case also triggers a swap
//       // (cascading full reversal), so compared == swapping == 10 each.
//       final input = [5, 4, 3, 2, 1];
//       final result = notifier.buildSorting(input);
//
//       expect(result.sortedValues, equals([1, 2, 3, 4, 5]));
//
//       final comparedCount = result.steps.where((s) => s.action == SortingStatus.compared).length;
//       final swappingCount = result.steps.where((s) => s.action == SortingStatus.swapping).length;
//
//       expect(comparedCount, 10);
//       expect(swappingCount, 10);
//       expect(result.steps.length, 20);
//     });
//
//     test('list with duplicate values sorts correctly (stability of *values*, not identity)', () {
//       final input = [3, 1, 3, 2, 1];
//       final result = notifier.buildSorting(input);
//       expect(result.sortedValues, equals([1, 1, 2, 2, 3].map((e) => e).toList()..sort()));
//       expect(result.sortedValues, equals([1, 1, 2, 2, 3]));
//     });
//
//     test('every step touches two adjacent indices within array bounds', () {
//       final input = [8, 3, 7, 1, 9, 2, 6, 4, 5];
//       final result = notifier.buildSorting(input);
//
//       for (final step in result.steps) {
//         expect(step.index2, step.index1 + 1, reason: 'bubble sort only ever compares adjacent slots');
//         expect(step.index1, greaterThanOrEqualTo(0));
//         expect(step.index2, lessThan(input.length));
//         expect(
//           step.action == SortingStatus.compared || step.action == SortingStatus.swapping,
//           isTrue,
//           reason: 'buildSorting should never itself emit none/allSorted steps',
//         );
//       }
//     });
//
//     test('replaying the emitted swap steps against the original array reconstructs sortedValues', () {
//       // This is a strong end-to-end check: it proves the *steps* returned
//       // are not just cosmetic but are an accurate, replayable trace of how
//       // the algorithm actually got from input -> output. This mirrors what
//       // SortingNotifier._computeSnapshots() does when building playback frames.
//       final input = [9, 1, 8, 2, 7, 3, 6, 4, 5, 0];
//       final result = notifier.buildSorting(input);
//
//       final replay = List<int>.from(input);
//       for (final step in result.steps) {
//         if (step.action == SortingStatus.swapping) {
//           final tmp = replay[step.index1];
//           replay[step.index1] = replay[step.index2];
//           replay[step.index2] = tmp;
//         }
//       }
//
//       expect(replay, equals(result.sortedValues));
//     });
//
//     test('is a stable sort with respect to equal-valued original ordering under swap replay', () {
//       // Bubble sort is textbook-stable: equal elements should never cross
//       // each other. We tag each value with its original index to detect
//       // any inversion among ties.
//       final tagged = <List<int>>[
//         [3, 0],
//         [1, 1],
//         [3, 2],
//         [1, 3],
//         [2, 4],
//       ]; // [value, originalIndex]
//
//       final values = tagged.map((t) => t[0]).toList();
//       final result = notifier.buildSorting(values);
//
//       // Replay swaps on the tagged list to track original indices through the sort.
//       final replay = List<List<int>>.from(tagged);
//       for (final step in result.steps) {
//         if (step.action == SortingStatus.swapping) {
//           final tmp = replay[step.index1];
//           replay[step.index1] = replay[step.index2];
//           replay[step.index2] = tmp;
//         }
//       }
//
//       // For every pair of equal values, the one with the smaller original
//       // index must still appear first.
//       for (int i = 0; i < replay.length; i++) {
//         for (int j = i + 1; j < replay.length; j++) {
//           if (replay[i][0] == replay[j][0]) {
//             expect(replay[i][1], lessThan(replay[j][1]),
//                 reason: 'equal elements must preserve relative order (stability)');
//           }
//         }
//       }
//     });
//
//     test('is a permutation of the input (no values invented or dropped)', () {
//       final input = [5, -2, 0, 17, 3, -8, 5, 2];
//       final result = notifier.buildSorting(input);
//
//       final sortedInput = List<int>.from(input)..sort();
//       final sortedOutput = List<int>.from(result.sortedValues)..sort();
//       expect(sortedOutput, equals(sortedInput));
//     });
//
//     test('handles negative and repeated-extreme values', () {
//       final input = [-1, -1, -1];
//       final result = notifier.buildSorting(input);
//       expect(result.sortedValues, equals([-1, -1, -1]));
//     });
//
//     test('randomized property check across many sizes/seeds', () {
//       // Deterministic pseudo-random generator so failures are reproducible.
//       int seed = 12345;
//       int next() {
//         seed = (seed * 1103515245 + 12345) & 0x7fffffff;
//         return seed;
//       }
//
//       for (int trial = 0; trial < 50; trial++) {
//         final size = next() % 20; // 0..19
//         final input = List.generate(size, (_) => (next() % 200) - 100);
//         final result = notifier.buildSorting(input);
//
//         final expected = List<int>.from(input)..sort();
//         expect(result.sortedValues, equals(expected), reason: 'trial=$trial input=$input');
//
//         // Cross-check the step trace matches the final result.
//         final replay = List<int>.from(input);
//         for (final step in result.steps) {
//           if (step.action == SortingStatus.swapping) {
//             final tmp = replay[step.index1];
//             replay[step.index1] = replay[step.index2];
//             replay[step.index2] = tmp;
//           }
//         }
//         expect(replay, equals(result.sortedValues), reason: 'trial=$trial input=$input');
//       }
//     });
//   });
//
//   group('BubbleSortNotifier — metadata', () {
//     test('algorithmComplexity reports expected Big-O characteristics', () {
//       final complexity = BubbleSortNotifier.algorithmComplexity;
//       expect(complexity.bestTimeComplexity, ONotationComplexity.n);
//       expect(complexity.averageTimeComplexity, ONotationComplexity.n2);
//       expect(complexity.worstTimeComplexity, ONotationComplexity.n2);
//       expect(complexity.spaceComplexity, ONotationComplexity.constant);
//       expect(complexity.stable, isTrue);
//     });
//
//     test('algoComplexity instance getter matches the static definition', () {
//       expect(notifier.algoComplexity, equals(BubbleSortNotifier.algorithmComplexity));
//     });
//
//     test('codeLineForStep maps each action to the right highlighted source line', () {
//       SortingStep step(SortingStatus action) => SortingStep(index1: 0, index2: 1, action: action);
//
//       expect(notifier.codeLineForStep(step(SortingStatus.compared)), 6);
//       expect(notifier.codeLineForStep(step(SortingStatus.swapping)), 8);
//       expect(notifier.codeLineForStep(step(SortingStatus.none)), 5);
//       expect(notifier.codeLineForStep(step(SortingStatus.allSorted)), -1);
//     });
//
//     test('codeSnippet is non-empty and every codeLineForStep index is in range', () {
//       final snippet = notifier.codeSnippet;
//       expect(snippet, isNotEmpty);
//
//       for (final action in [
//         SortingStatus.compared,
//         SortingStatus.swapping,
//         SortingStatus.none,
//       ]) {
//         final line = notifier.codeLineForStep(SortingStep(index1: 0, index2: 1, action: action));
//         expect(line, inInclusiveRange(0, snippet.length - 1),
//             reason: '$action should point at a real line in codeSnippet');
//       }
//     });
//   });
// }
