import 'package:algorithm_visualizer/config/themes/app_theme.dart';
import 'package:algorithm_visualizer/core/localization/app_localizations.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/view/searching_view.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/widgets/pf_grid.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view/sorting_view.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/widgets/control_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// Leaving the visualize tab must stop the running animation. The shell mutes
/// an inactive branch's `TickerMode`, and both views listen for that to pause
/// themselves — so this pins the pause to the signal the app actually gets,
/// rather than to a method call a refactor could quietly disconnect.
///
/// Searching used to fail this: `_jump` assigned `instance` inside the view's
/// deferred `setState`, so the notifier it cached was dropped by auto-dispose
/// and rebuilt, and the pause was aimed at the discarded one.
const Size _surface = Size(430, 932);

/// Lets a test flip the `TickerMode` the way switching nav tabs does.
class _TabHost extends StatefulWidget {
  const _TabHost({required this.child});

  final Widget child;

  @override
  State<_TabHost> createState() => _TabHostState();
}

class _TabHostState extends State<_TabHost> {
  bool enabled = true;

  void leaveTab() => setState(() => enabled = false);

  @override
  Widget build(BuildContext context) => TickerMode(enabled: enabled, child: widget.child);
}

Future<void> _pumpView(WidgetTester tester, Widget view, ProviderContainer container) async {
  await tester.binding.setSurfaceSize(_surface);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: ScreenUtilInit(
        designSize: _surface,
        builder: (context, _) => MaterialApp(
          theme: AppTheme.dark,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(body: _TabHost(child: view)),
        ),
      ),
    ),
  );

  // Two frames: the views finish wiring themselves up in a post-frame callback.
  await tester.pump();
  await tester.pump();
}

/// Flips the ticker off, then lets the queued pause run.
Future<void> _leaveTab(WidgetTester tester) async {
  tester.state<_TabHostState>(find.byType(_TabHost)).leaveTab();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

/// Tears the tree down and drains what is still in flight, so neither the
/// queued pause nor a play loop suspended on its frame delay outlives the test.
Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 2));
  await tester.pump(const Duration(seconds: 2));
}

void main() {
  testWidgets('searching stops playing when the tab is left', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await _pumpView(tester, SearchingView(onAlgoChanged: (_, __, ___) {}), container);

    final instance = tester.widget<PFGrid>(find.byType(PFGrid)).instance;
    final notifier = container.read(instance.notifier);

    notifier.togglePlay();
    await tester.pump();
    expect(notifier.isPlaying, isTrue, reason: 'playback never started, so nothing is proven');

    await _leaveTab(tester);

    expect(notifier.isPlaying, isFalse, reason: 'the search kept running on a hidden tab');

    await _unmount(tester);
  });

  testWidgets('sorting stops playing when the tab is left', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await _pumpView(tester, SortingView(onAlgoChanged: (_, __, ___) {}), container);

    final instance = tester.widget<SortingControlButtons>(
      find.byType(SortingControlButtons),
    ).notifier;
    final notifier = container.read(instance.notifier);

    notifier.togglePlay();
    await tester.pump();
    expect(notifier.isPlaying, isTrue, reason: 'playback never started, so nothing is proven');

    await _leaveTab(tester);

    expect(notifier.isPlaying, isFalse, reason: 'the sort kept running on a hidden tab');

    await _unmount(tester);
  });
}
