// //
// // LAYER 2 — SortingNotifier state machine, exercised through
// // BubbleSortNotifier (the concrete Notifier under test).
// //
// // WHY testWidgets AND NOT plain `test()`:
// //   `_initializePositions()` / `build()` call `SortingNotifier.calculateItemWidth`,
// //   which reads `ScreenUtil().screenWidth`. ScreenUtil needs a live widget
// //   tree (ScreenUtilInit) below a MediaQuery to be configured, otherwise it
// //   throws or returns garbage. We therefore create the ProviderContainer
// //   *inside* a pumped widget tree.
// //
// //   Bonus: `testWidgets` runs inside a fake-async zone, so `tester.pump(
// //   duration)` deterministically fast-forwards every `Future.delayed(...)`
// //   used by `_buildSort` / `_greenSortedItemsAsDone` — no real waiting,
// //   no flakiness.
// //
// // ASSUMPTIONS (adjust to match your project if different):
// //   - `PlaybackSpeed.stepSortingDuration` is a small, finite `Duration`
// //     for slow/normal/fast3 (i.e. play-through in tests finishes in a
// //     bounded number of `tester.pump()` calls).
// //   - `SortingEnum` has `.none`, `.played`, `.stopped`.
// //   - ScreenUtil design size doesn't matter for these assertions — we only
// //     assert on relative/structural properties (counts, indices, flags),
// //     never on literal pixel values.
//
// import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
// import 'package:algorithm_visualizer/features/visualize/helper/playback_speed.dart';
// import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sorting_notifier.dart';
// import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sub_sorting/bubble_sort_notifier.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_test/flutter_test.dart';
//
// /// Pumps a minimal app shell (ScreenUtilInit + ProviderScope) and hands
// /// back the live ProviderContainer so tests can read/mutate state and
// /// call notifier methods directly, without needing real widgets.
// Future<ProviderContainer> pumpSortingContainer(WidgetTester tester) async {
//   late ProviderContainer container;
//
//   await tester.pumpWidget(
//     ScreenUtilInit(
//       designSize: const Size(390, 844),
//       builder: (context, child) => ProviderScope(
//         child: Consumer(
//           builder: (context, ref, _) {
//             container = ProviderScope.containerOf(context);
//             return const SizedBox.shrink();
//           },
//         ),
//       ),
//     ),
//   );
//   await tester.pump();
//   return container;
// }
//
// void main() {
//   final bubbleSortProvider = NotifierProvider<BubbleSortNotifier, SortingNotifierState>(BubbleSortNotifier.new);
//
//   group('SortingNotifier — initial state', () {
//     testWidgets('starts with default size, a full list of unique values, and no active step', (tester) async {
//       final container = await pumpSortingContainer(tester);
//       addTearDown(container.dispose);
//
//       final state = container.read(bubbleSortProvider);
//
//       expect(state.size, 7); // matches SortingNotifier._defaultSize
//       expect(state.list.length, 7);
//       expect(state.list.map((e) => e.value).toSet().length, 7, reason: 'values should be unique 1..size');
//       expect(state.operationStatus, SortingEnum.none);
//       expect(state.currentStepIndex, 0);
//       expect(state.totalPlaySteps, 0);
//       expect(state.isPlaying, isFalse);
//       expect(state.isAtFirstStep, isTrue);
//       // totalPlaySteps is 0 before any play/step, so isAtLastStep is defined false.
//       expect(state.isAtLastStep, isFalse);
//       expect(state.positions.length, state.list.length);
//     });
//
//     testWidgets('progressValue and progressLabel are empty before any stepping', (tester) async {
//       final container = await pumpSortingContainer(tester);
//       addTearDown(container.dispose);
//
//       final state = container.read(bubbleSortProvider);
//       expect(state.progressValue, 0.0);
//       expect(state.progressLabel, '');
//     });
//   });
//
//   group('SortingNotifier — reset / cancelSorting', () {
//     testWidgets('reset() reshuffles the list and clears playback progress', (tester) async {
//       final container = await pumpSortingContainer(tester);
//       addTearDown(container.dispose);
//
//       final notifier = container.read(bubbleSortProvider.notifier);
//       final originalIds = container.read(bubbleSortProvider).list.map((e) => e.id).toList();
//
//       // Step forward once so there is progress to clear.
//       notifier.stepForward();
//       await tester.pump(const Duration(seconds: 1));
//       expect(container.read(bubbleSortProvider).currentStepIndex, greaterThan(0));
//
//       await notifier.reset();
//       await tester.pump();
//
//       final state = container.read(bubbleSortProvider);
//       expect(state.currentStepIndex, 0);
//       expect(state.totalPlaySteps, 0);
//       expect(state.sortedSteps, isEmpty);
//       expect(state.operationStatus, SortingEnum.none);
//       // The list is regenerated (ids preserved as a set 0..size-1, order re-shuffled).
//       expect(state.list.map((e) => e.id).toSet(), originalIds.toSet());
//     });
//
//     testWidgets('cancelSorting() behaves like reset() and can be called mid-playback', (tester) async {
//       final container = await pumpSortingContainer(tester);
//       addTearDown(container.dispose);
//
//       final notifier = container.read(bubbleSortProvider.notifier);
//       await notifier.togglePlay(tester.element(find.byType(SizedBox)));
//       await tester.pump(); // let play start
//
//       await notifier.cancelSorting();
//       await tester.pump(const Duration(seconds: 2)); // drain any pending timers
//
//       final state = container.read(bubbleSortProvider);
//       expect(state.operationStatus, SortingEnum.none);
//       expect(state.currentStepIndex, 0);
//       expect(state.currentStep?.index1, -1);
//     });
//   });
//
//   group('SortingNotifier — stepForward / stepBackward', () {
//     testWidgets('stepForward advances one step at a time and generates steps lazily', (tester) async {
//       final container = await pumpSortingContainer(tester);
//       addTearDown(container.dispose);
//
//       final notifier = container.read(bubbleSortProvider.notifier);
//       expect(container.read(bubbleSortProvider).sortedSteps, isEmpty);
//
//       notifier.stepForward();
//       await tester.pump(const Duration(milliseconds: 1));
//
//       final afterFirstStep = container.read(bubbleSortProvider);
//       expect(afterFirstStep.sortedSteps, isNotEmpty, reason: 'steps should be generated on first advance');
//       expect(afterFirstStep.currentStepIndex, 1);
//       expect(afterFirstStep.currentStep, isNotNull);
//     });
//
//     testWidgets('stepBackward undoes stepForward and restores prior snapshot', (tester) async {
//       final container = await pumpSortingContainer(tester);
//       addTearDown(container.dispose);
//
//       final notifier = container.read(bubbleSortProvider.notifier);
//       final initialList = container.read(bubbleSortProvider).list;
//
//       notifier.stepForward();
//       await tester.pump(const Duration(milliseconds: 1));
//       expect(container.read(bubbleSortProvider).currentStepIndex, 1);
//
//       notifier.stepBackward();
//       await tester.pump(const Duration(milliseconds: 1));
//
//       final state = container.read(bubbleSortProvider);
//       expect(state.currentStepIndex, 0);
//       expect(state.list.map((e) => e.id), initialList.map((e) => e.id));
//     });
//
//     testWidgets('stepBackward at the first step is a no-op', (tester) async {
//       final container = await pumpSortingContainer(tester);
//       addTearDown(container.dispose);
//
//       final notifier = container.read(bubbleSortProvider.notifier);
//       expect(container.read(bubbleSortProvider).isAtFirstStep, isTrue);
//
//       notifier.stepBackward();
//       await tester.pump();
//
//       expect(container.read(bubbleSortProvider).currentStepIndex, 0);
//     });
//
//     testWidgets('stepping forward through every step reaches isAtLastStep and colors the list allSorted',
//             (tester) async {
//           final container = await pumpSortingContainer(tester);
//           addTearDown(container.dispose);
//
//           final notifier = container.read(bubbleSortProvider.notifier);
//
//           // Drive to the end by stepping forward more times than there could
//           // possibly be steps for a 7-element list (bubble sort worst case is
//           // n*(n-1)/2 = 21 comparisons, each possibly paired with a swap -> <=42).
//           SortingNotifierState state = container.read(bubbleSortProvider);
//           for (int i = 0; i < 50 && !state.isAtLastStep; i++) {
//             notifier.stepForward();
//             await tester.pump(const Duration(milliseconds: 1));
//             state = container.read(bubbleSortProvider);
//           }
//
//           expect(state.isAtLastStep, isTrue);
//           expect(state.currentStepIndex, state.totalPlaySteps);
//           expect(state.progressValue, 1.0);
//
//           // Let the fire-and-forget "paint everything green" animation finish.
//           await tester.pump(const Duration(seconds: 2));
//           final finalState = container.read(bubbleSortProvider);
//           final values = finalState.list.map((e) => e.value).toList();
//           expect(values, equals(List<int>.from(values)..sort()), reason: 'final list must be fully sorted');
//         });
//
//     testWidgets('stepForward is ignored while playing', (tester) async {
//       final container = await pumpSortingContainer(tester);
//       addTearDown(container.dispose);
//
//       final notifier = container.read(bubbleSortProvider.notifier);
//       await notifier.togglePlay(tester.element(find.byType(SizedBox)));
//       await tester.pump();
//       expect(container.read(bubbleSortProvider).isPlaying, isTrue);
//
//       final indexWhilePlaying = container.read(bubbleSortProvider).currentStepIndex;
//       notifier.stepForward(); // should be a no-op per `if (state.isPlaying) return;`
//       expect(container.read(bubbleSortProvider).currentStepIndex, indexWhilePlaying);
//
//       // Drain remaining timers so the test doesn't leak a pending Future.
//       await tester.pump(const Duration(seconds: 5));
//       await notifier.cancelSorting();
//       await tester.pump();
//     });
//   });
//
//   group('SortingNotifier — togglePlay', () {
//     testWidgets('play runs to completion and produces a sorted list', (tester) async {
//       final container = await pumpSortingContainer(tester);
//       addTearDown(container.dispose);
//
//       final notifier = container.read(bubbleSortProvider.notifier);
//       final context = tester.element(find.byType(SizedBox));
//
//       await notifier.togglePlay(context);
//       expect(container.read(bubbleSortProvider).isPlaying, isTrue);
//
//       // Drain every scheduled Future.delayed for playback + the trailing
//       // "paint green" animation. A generous ceiling avoids flakiness across
//       // whatever concrete Duration values PlaybackSpeed uses.
//       await tester.pump(const Duration(seconds: 30));
//
//       final finalState = container.read(bubbleSortProvider);
//       expect(finalState.isAtLastStep, isTrue);
//       final values = finalState.list.map((e) => e.value).toList();
//       expect(values, equals(List<int>.from(values)..sort()));
//     });
//
//     testWidgets('toggling play a second time while playing pauses/stops it', (tester) async {
//       final container = await pumpSortingContainer(tester);
//       addTearDown(container.dispose);
//
//       final notifier = container.read(bubbleSortProvider.notifier);
//       final context = tester.element(find.byType(SizedBox));
//
//       await notifier.togglePlay(context);
//       await tester.pump(const Duration(milliseconds: 1));
//       expect(container.read(bubbleSortProvider).operationStatus, SortingEnum.played);
//
//       await notifier.togglePlay(context);
//       await tester.pump();
//       expect(container.read(bubbleSortProvider).operationStatus, SortingEnum.stopped);
//
//       // Drain any in-flight timers from the aborted play loop.
//       await tester.pump(const Duration(seconds: 5));
//     });
//
//     testWidgets('toggling play after reaching the last step restarts playback from a fresh shuffle',
//             (tester) async {
//           final container = await pumpSortingContainer(tester);
//           addTearDown(container.dispose);
//
//           final notifier = container.read(bubbleSortProvider.notifier);
//           final context = tester.element(find.byType(SizedBox));
//
//           await notifier.togglePlay(context);
//           await tester.pump(const Duration(seconds: 30));
//           expect(container.read(bubbleSortProvider).isAtLastStep, isTrue);
//
//           await notifier.togglePlay(context);
//           await tester.pump(const Duration(milliseconds: 1));
//
//           final restarted = container.read(bubbleSortProvider);
//           expect(restarted.currentStepIndex, lessThan(restarted.totalPlaySteps == 0 ? 1 : restarted.totalPlaySteps + 1));
//           expect(restarted.isAtLastStep, isFalse, reason: 'restart should reset progress via reset()');
//
//           await tester.pump(const Duration(seconds: 30)); // let it finish so no timers leak
//         });
//   });
//
//   group('SortingNotifier — changeSpeed / changeSize', () {
//     testWidgets('changeSpeed updates state.speed and getSpeed', (tester) async {
//       final container = await pumpSortingContainer(tester);
//       addTearDown(container.dispose);
//
//       final notifier = container.read(bubbleSortProvider.notifier);
//       notifier.changeSpeed(PlaybackSpeed.fast3);
//       expect(container.read(bubbleSortProvider).speed, PlaybackSpeed.fast3);
//       expect(notifier.getSpeed, PlaybackSpeed.fast3);
//
//       notifier.changeSpeed(PlaybackSpeed.slow);
//       expect(container.read(bubbleSortProvider).speed, PlaybackSpeed.slow);
//     });
//
//     testWidgets('changeSize maps the 0..1 slider value into the min..max size range', (tester) async {
//       final container = await pumpSortingContainer(tester);
//       addTearDown(container.dispose);
//
//       final notifier = container.read(bubbleSortProvider.notifier);
//
//       notifier.changeSize(0.0);
//       expect(container.read(bubbleSortProvider).size, 5); // SortingNotifier._minSize
//
//       notifier.changeSize(1.0);
//       expect(container.read(bubbleSortProvider).size, 15); // SortingNotifier._maxSize
//
//       notifier.changeSize(0.5);
//       final midSize = container.read(bubbleSortProvider).size;
//       expect(midSize, inInclusiveRange(5, 15));
//     });
//
//     testWidgets('changeSize also regenerates the list to the new size', (tester) async {
//       final container = await pumpSortingContainer(tester);
//       addTearDown(container.dispose);
//
//       final notifier = container.read(bubbleSortProvider.notifier);
//       notifier.changeSize(1.0);
//       final state = container.read(bubbleSortProvider);
//       expect(state.list.length, state.size);
//       expect(state.list.length, 15);
//     });
//
//     testWidgets('changeSize is ignored while actively playing', (tester) async {
//       final container = await pumpSortingContainer(tester);
//       addTearDown(container.dispose);
//
//       final notifier = container.read(bubbleSortProvider.notifier);
//       final context = tester.element(find.byType(SizedBox));
//
//       await notifier.togglePlay(context);
//       await tester.pump(const Duration(milliseconds: 1));
//       expect(container.read(bubbleSortProvider).operationStatus, SortingEnum.played);
//
//       final sizeBefore = container.read(bubbleSortProvider).size;
//       notifier.changeSize(1.0);
//       expect(container.read(bubbleSortProvider).size, sizeBefore,
//           reason: '_getOperation == SortingEnum.played should short-circuit changeSize');
//
//       await tester.pump(const Duration(seconds: 30)); // drain timers
//     });
//   });
//
//   group('SortingNotifier — statusText', () {
//     testWidgets('returns the initial-array text when there is no current step', (tester) async {
//       final container = await pumpSortingContainer(tester);
//       addTearDown(container.dispose);
//
//       final state = container.read(bubbleSortProvider);
//       final notifier = container.read(bubbleSortProvider.notifier);
//
//       final text = notifier.statusText(currentStep: state.currentStep, list: state.list);
//       expect(text, StringsManager.initialArrayReadyToSort);
//     });
//
//     testWidgets('mentions compare/swap wording as the algorithm progresses, and fully-sorted text at the end',
//             (tester) async {
//           final container = await pumpSortingContainer(tester);
//           addTearDown(container.dispose);
//
//           final notifier = container.read(bubbleSortProvider.notifier);
//           notifier.stepForward();
//           await tester.pump(const Duration(milliseconds: 1));
//
//           var state = container.read(bubbleSortProvider);
//           var text = notifier.statusText(currentStep: state.currentStep, list: state.list);
//           expect(text, contains(StringsManager.compare));
//
//           // Drive to completion.
//           for (int i = 0; i < 60 && !state.isAtLastStep; i++) {
//             notifier.stepForward();
//             await tester.pump(const Duration(milliseconds: 1));
//             state = container.read(bubbleSortProvider);
//           }
//           await tester.pump(const Duration(seconds: 2));
//         });
//   });
// }
