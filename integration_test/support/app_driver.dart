import 'package:algorithm_visualizer/bootstrap.dart';
import 'package:algorithm_visualizer/core/flavor/flavor_config.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:flutter_test/flutter_test.dart';

/// Boots the real app exactly as `lib/main_dev.dart` does, and settles it.
/// Every on-device scenario in this suite starts from this same state.
Future<void> launchApp(WidgetTester tester) async {
  await bootstrap(FlavorConfig.fromEnvironment());
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

/// Tab labels in `_AuroraNavBar`'s fixed order — matches
/// `lib/features/base/view/base_navigation.dart`.
const List<String> tabLabels = [
  StringsManager.home,
  StringsManager.visual,
  StringsManager.code,
  StringsManager.practice,
  StringsManager.profile,
];

/// Taps the named bottom-nav tab and settles.
Future<void> goToTab(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

/// Scrolls [finder] up and down repeatedly for [duration], at real device
/// frame rate, so the recorded [FrameTiming]s reflect sustained scrolling
/// rather than one single fling (SC-001's "10-second continuous scroll pass").
Future<void> continuousScroll(
  WidgetTester tester,
  Finder finder, {
  required Duration duration,
  double distance = 400,
}) async {
  const passDuration = Duration(milliseconds: 900);
  var elapsed = Duration.zero;
  var goingDown = true;
  while (elapsed < duration) {
    await tester.timedDrag(
      finder,
      Offset(0, goingDown ? -distance : distance),
      passDuration,
    );
    goingDown = !goingDown;
    elapsed += passDuration;
  }
}
