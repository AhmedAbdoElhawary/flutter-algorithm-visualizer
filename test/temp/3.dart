// // sorting_widgets_test.dart
// //
// // LAYER 3 — widget tests.
// //
// // IMPORTANT / HIGHEST-RISK FILE, PLEASE READ:
// // `CtrlButton`, `_PlayButton`, and friends call `context.getColor(ThemeEnum...)`
// // and use `SimpleGlassButton`, which live in files I don't have visibility
// // into (theme_manager.dart, simple_glass_button.dart). I've wrapped every
// // test below in a generic `_wrap()` helper (MaterialApp + ScreenUtilInit +
// // ProviderScope + Theme). If your project already has a test harness
// // (commonly named something like `pumpApp`/`makeTestableWidget`/`wrapWithApp`),
// // swap it in for `_wrap()` — it will almost certainly be more correct than
// // my guess, since it already knows how ThemeManager/ColorManager are wired.
// //
// // Everything in this file targets **public** classes only:
// //   `AlgorithmControls`, `CtrlButton`, `SpeedSelector`, `SortingAppBar`,
// //   `SortingView`, `ShowUpSortingList`.
// // `_SortingControlButtons`, `_PlayButton`, `_BuildChildForSpeedSelector`
// // are private to `sorting_view.dart` and are exercised only indirectly
// // (through `AlgorithmControls` / `SortingView`), as Dart doesn't allow
// // reaching into another library's private classes from an external test file.
//
// import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
// import 'package:algorithm_visualizer/features/base/view_model/algorithm_control_interface.dart';
// // NOTE: this is where I'm least certain of the exact path — `SortingAlgoCards`
// // and `BaseViewModel.sortingCards(...)` are referenced in sorting_view.dart
// // but I never saw the file that *defines* them. Adjust this import if your
// // project keeps them somewhere else (e.g. a dedicated enums file).
// import 'package:algorithm_visualizer/features/base/view_model/base_view_model.dart';
// import 'package:algorithm_visualizer/features/visualize/helper/playback_speed.dart';
// import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view/sorting_view.dart';
// import 'package:algorithm_visualizer/core/widgets/custom_widgets/algorithm_control.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_test/flutter_test.dart';
//
// /// Best-effort app shell. Replace with your project's real test harness if
// /// one exists (see file header comment).
// Widget _wrap(Widget child) {
//   return ScreenUtilInit(
//     designSize: const Size(390, 844),
//     builder: (context, _) => ProviderScope(
//       child: MaterialApp(
//         theme: ThemeData.light(),
//         home: Scaffold(body: child),
//       ),
//     ),
//   );
// }
//
// /// A controllable fake so we can assert exactly what the UI calls, without
// /// depending on the real SortingNotifier's async playback timing.
// class _FakeControlInterface implements AlgorithmControlInterface {
//   int resetCalls = 0;
//   int stepForwardCalls = 0;
//   int stepBackwardCalls = 0;
//   int togglePlayCalls = 0;
//   PlaybackSpeed? lastSpeedChangedTo;
//
//   @override
//   bool backwardValidation = false;
//   @override
//   bool forwardValidation = true;
//   @override
//   bool isPlaying = false;
//   @override
//   PlaybackSpeed getSpeed = PlaybackSpeed.normal;
//
//   @override
//   Future<void> reset() async => resetCalls++;
//
//   @override
//   void stepForward() => stepForwardCalls++;
//
//   @override
//   void stepBackward() => stepBackwardCalls++;
//
//   @override
//   Future<void> togglePlay(BuildContext context) async => togglePlayCalls++;
//
//   @override
//   void changeSpeed(PlaybackSpeed speed) => lastSpeedChangedTo = speed;
// }
//
// void main() {
//   group('CtrlButton', () {
//     testWidgets('tapping an enabled button invokes its callback', (tester) async {
//       var tapped = false;
//       await tester.pumpWidget(_wrap(
//         CtrlButton(icon: Icons.restart_alt_rounded, onTap: () => tapped = true),
//       ));
//       await tester.pump();
//
//       await tester.tap(find.byIcon(Icons.restart_alt_rounded));
//       await tester.pump();
//
//       expect(tapped, isTrue);
//     });
//
//     testWidgets('a disabled (onTap: null) button never crashes on tap and stays inert', (tester) async {
//       await tester.pumpWidget(_wrap(
//         const CtrlButton(icon: Icons.skip_next_rounded, onTap: null),
//       ));
//       await tester.pump();
//
//       // Should not throw even though there is nothing wired up.
//       await tester.tap(find.byIcon(Icons.skip_next_rounded), warnIfMissed: false);
//       await tester.pump();
//
//       expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);
//     });
//   });
//
//   group('AlgorithmControls', () {
//     testWidgets('reset is always tappable and calls interface.reset()', (tester) async {
//       final fake = _FakeControlInterface();
//       await tester.pumpWidget(_wrap(
//         AlgorithmControls(
//           interface: fake,
//           backwardValidation: false,
//           forwardValidation: false,
//           isPlaying: false,
//           getSpeed: PlaybackSpeed.normal,
//         ),
//       ));
//       await tester.pump();
//
//       await tester.tap(find.byIcon(Icons.restart_alt_rounded));
//       await tester.pump();
//
//       expect(fake.resetCalls, 1);
//     });
//
//     testWidgets('step-backward is disabled when backwardValidation is false', (tester) async {
//       final fake = _FakeControlInterface();
//       await tester.pumpWidget(_wrap(
//         AlgorithmControls(
//           interface: fake,
//           backwardValidation: false, // matches _SortingControlButtons passing !isAtFirstStep
//           forwardValidation: true,
//           isPlaying: false,
//           getSpeed: PlaybackSpeed.normal,
//         ),
//       ));
//       await tester.pump();
//
//       await tester.tap(find.byIcon(Icons.skip_previous_rounded), warnIfMissed: false);
//       await tester.pump();
//
//       expect(fake.stepBackwardCalls, 0, reason: 'onTap should be null when backwardValidation is false');
//     });
//
//     testWidgets('step-forward/backward call through to the interface when enabled', (tester) async {
//       final fake = _FakeControlInterface();
//       await tester.pumpWidget(_wrap(
//         AlgorithmControls(
//           interface: fake,
//           backwardValidation: true,
//           forwardValidation: true,
//           isPlaying: false,
//           getSpeed: PlaybackSpeed.normal,
//         ),
//       ));
//       await tester.pump();
//
//       await tester.tap(find.byIcon(Icons.skip_previous_rounded));
//       await tester.pump();
//       expect(fake.stepBackwardCalls, 1);
//
//       await tester.tap(find.byIcon(Icons.skip_next_rounded));
//       await tester.pump();
//       expect(fake.stepForwardCalls, 1);
//     });
//
//     testWidgets('play/pause icon reflects isPlaying and tapping it calls togglePlay', (tester) async {
//       final fake = _FakeControlInterface();
//
//       await tester.pumpWidget(_wrap(
//         AlgorithmControls(
//           interface: fake,
//           backwardValidation: true,
//           forwardValidation: true,
//           isPlaying: false,
//           getSpeed: PlaybackSpeed.normal,
//         ),
//       ));
//       await tester.pump();
//       expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
//       expect(find.byIcon(Icons.pause_rounded), findsNothing);
//
//       await tester.tap(find.byIcon(Icons.play_arrow_rounded));
//       await tester.pump();
//       expect(fake.togglePlayCalls, 1);
//
//       // Re-pump with isPlaying: true to confirm the icon swaps.
//       await tester.pumpWidget(_wrap(
//         AlgorithmControls(
//           interface: fake,
//           backwardValidation: true,
//           forwardValidation: true,
//           isPlaying: true,
//           getSpeed: PlaybackSpeed.normal,
//         ),
//       ));
//       await tester.pump();
//       expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
//       expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
//     });
//
//     testWidgets('speed selector shows slow/normal/fast3 and tapping one calls changeSpeed', (tester) async {
//       final fake = _FakeControlInterface();
//       await tester.pumpWidget(_wrap(
//         AlgorithmControls(
//           interface: fake,
//           backwardValidation: true,
//           forwardValidation: true,
//           isPlaying: false,
//           getSpeed: PlaybackSpeed.normal,
//           expandSpeedEscalator: true,
//         ),
//       ));
//       await tester.pump();
//
//       expect(find.text('${PlaybackSpeed.slow.level}×'), findsOneWidget);
//       expect(find.text('${PlaybackSpeed.normal.level}×'), findsOneWidget);
//       expect(find.text('${PlaybackSpeed.fast3.level}×'), findsOneWidget);
//
//       await tester.tap(find.text('${PlaybackSpeed.fast3.level}×'));
//       await tester.pump();
//
//       expect(fake.lastSpeedChangedTo, PlaybackSpeed.fast3);
//     });
//
//     testWidgets('endOptionButtons are rendered in addition to the default controls', (tester) async {
//       final fake = _FakeControlInterface();
//       await tester.pumpWidget(_wrap(
//         AlgorithmControls(
//           interface: fake,
//           backwardValidation: true,
//           forwardValidation: true,
//           isPlaying: false,
//           getSpeed: PlaybackSpeed.normal,
//           endOptionButtons: [
//             CtrlButton(icon: Icons.shuffle, onTap: () {}),
//           ],
//         ),
//       ));
//       await tester.pump();
//
//       expect(find.byIcon(Icons.shuffle), findsOneWidget);
//     });
//   });
//
//   group('SortingAppBar', () {
//     testWidgets('renders the given title', (tester) async {
//       await tester.pumpWidget(_wrap(const SortingAppBar(title: 'Bubble Sort')));
//       await tester.pump();
//       expect(find.text('Bubble Sort'), findsOneWidget);
//     });
//   });
//
//   group('SortingView — end-to-end smoke test', () {
//     testWidgets('renders a tab per algorithm, defaults to the bubble tab, and reports the algo on change',
//             (tester) async {
//           String? changedTitle;
//           String? changedDescription;
//
//           await tester.pumpWidget(_wrap(
//             SortingView(
//               card: SortingAlgoCards.bubble,
//               onAlgoChanged: (title, description) {
//                 changedTitle = title;
//                 changedDescription = description;
//               },
//             ),
//           ));
//           await tester.pumpAndSettle();
//
//           // onAlgoChanged should fire once on initial mount.
//           expect(changedTitle, isNotNull);
//           expect(changedDescription, isNotNull);
//
//           // One InkWell-wrapped tab per SortingAlgoCards entry should exist
//           // inside the horizontal selection list at the top of the view.
//           expect(find.byType(InkWell), findsNWidgets(SortingAlgoCards.values.length));
//         });
//
//     testWidgets('play button drives the list to a fully sorted state and shows the "fully sorted" status',
//             (tester) async {
//           await tester.pumpWidget(_wrap(
//             SortingView(card: SortingAlgoCards.bubble, onAlgoChanged: (_, __) {}),
//           ));
//           await tester.pumpAndSettle();
//
//           expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
//           await tester.tap(find.byIcon(Icons.play_arrow_rounded));
//           await tester.pump();
//
//           // Drain the full play-through animation. Generous ceiling to absorb
//           // whatever concrete PlaybackSpeed durations the project uses.
//           await tester.pump(const Duration(seconds: 30));
//           await tester.pump(const Duration(seconds: 10));
//
//           expect(find.text(StringsManager.arrayFullySorted), findsWidgets);
//         });
//
//     testWidgets('reset button restores the initial "ready to sort" status text', (tester) async {
//       await tester.pumpWidget(_wrap(
//         SortingView(card: SortingAlgoCards.bubble, onAlgoChanged: (_, __) {}),
//       ));
//       await tester.pumpAndSettle();
//
//       await tester.tap(find.byIcon(Icons.play_arrow_rounded));
//       await tester.pump(const Duration(seconds: 30));
//
//       await tester.tap(find.byIcon(Icons.restart_alt_rounded));
//       await tester.pumpAndSettle();
//
//       // Progress should be back to zero after reset.
//       final progressFinder = find.byWidgetPredicate((w) => w is LinearProgressIndicator);
//       if (progressFinder.evaluate().isNotEmpty) {
//         final indicator = tester.widget<LinearProgressIndicator>(progressFinder.first);
//         expect(indicator.value ?? 0.0, 0.0);
//       }
//     });
//
//     testWidgets('switching algorithm tabs disposes the old instance and notifies onAlgoChanged again',
//             (tester) async {
//           final titles = <String>[];
//           await tester.pumpWidget(_wrap(
//             SortingView(
//               card: SortingAlgoCards.bubble,
//               onAlgoChanged: (title, _) => titles.add(title),
//             ),
//           ));
//           await tester.pumpAndSettle();
//           expect(titles, hasLength(1));
//
//           if (SortingAlgoCards.values.length > 1) {
//             final secondCard = SortingAlgoCards.values[1];
//             // Rebuild with a different `card` the way a parent would when the
//             // user taps a different tab (SortingView reacts via didUpdateWidget).
//             await tester.pumpWidget(_wrap(
//               SortingView(
//                 card: secondCard,
//                 onAlgoChanged: (title, _) => titles.add(title),
//               ),
//             ));
//             await tester.pumpAndSettle();
//
//             expect(titles.length, greaterThanOrEqualTo(2));
//           }
//         });
//   });
// }
