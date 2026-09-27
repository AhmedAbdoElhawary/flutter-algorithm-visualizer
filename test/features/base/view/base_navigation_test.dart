import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/base/view/base_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/screen_matrix.dart';

GoRouter _router(WidgetTester tester) => GoRouter.of(tester.element(find.byType(MainNavigationShell)));

String _location(WidgetTester tester) => _router(tester).routerDelegate.currentConfiguration.uri.path;

final _settings = '${Routes.profile.path}/${Routes.settings.path}';

const _tabs = [
  (StringsManager.home, '/home'),
  (StringsManager.visual, '/visualize'),
  (StringsManager.code, '/problem'),
  (StringsManager.practice, '/practice'),
  (StringsManager.profile, '/profile'),
];

/// Only the bar's own label, not a page title that happens to share the word.
Finder _tab(String label) => find.descendant(of: find.byType(MainNavigationShell), matching: find.text(label)).last;

Future<void> _openTab(WidgetTester tester, String label) async {
  await tester.tap(_tab(label));
  // Some pages spin while loading, so settling would never end; switching tabs has no transition.
  await tester.pump();
  await tester.pump();
}

/// A page pushed inside a tab slides in, which takes well under a second.
Future<void> _goInsideTab(WidgetTester tester, String location) async {
  _router(tester).go(location);
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

/// Leaving a page can queue work after the frame, so it has to run out.
Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testScreenMatrix('the bar shows every tab and fits the screen', (tester, variant) async {
    await pumpApp(
      tester,
      const SizedBox(),
      initialRoute: Routes.home.path,
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );
    await tester.pump();

    for (final (label, _) in _tabs) {
      expect(_tab(label), findsOneWidget, reason: label);
    }
    expect(tester.takeException(), isNull);
    await _unmount(tester);
  });

  testWidgets('each tab opens its page', (tester) async {
    await pumpApp(tester, const SizedBox(), initialRoute: Routes.home.path);
    await tester.pump();

    for (final (label, path) in _tabs.reversed) {
      await _openTab(tester, label);

      expect(_location(tester), path, reason: label);
    }
    await _unmount(tester);
  });

  testWidgets('tapping the open tab again goes back to its first page', (tester) async {
    await pumpApp(tester, const SizedBox(), initialRoute: Routes.home.path);
    await tester.pump();
    await _openTab(tester, StringsManager.profile);
    await _goInsideTab(tester, _settings);

    await _openTab(tester, StringsManager.profile);

    expect(_location(tester), Routes.profile.path);
    await _unmount(tester);
  });

  testWidgets('another tab keeps where it was', (tester) async {
    await pumpApp(tester, const SizedBox(), initialRoute: Routes.home.path);
    await tester.pump();
    await _openTab(tester, StringsManager.profile);
    await _goInsideTab(tester, _settings);

    await _openTab(tester, StringsManager.home);
    await _openTab(tester, StringsManager.profile);

    expect(_location(tester), _settings);
    await _unmount(tester);
  });
}
