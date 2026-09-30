import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/home/view/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/reset.dart';
import '../support/steps.dart';

void settingsJourney() {
  group('settings', () {
    testWidgets('a dark theme is still dark after a relaunch', (tester) async {
      await launchApp(tester);
      await skipOnboarding(tester);
      await openTab(tester, StringsManager.profile);
      await openSettings(tester);
      await tapOn(tester, find.text(StringsManager.themeDark));
      await tester.pump(const Duration(milliseconds: 500));

      await launchApp(tester);
      await pumpUntil(tester, find.byType(HomePage));
      expect(Theme.of(tester.element(find.byType(HomePage))).brightness, Brightness.dark);
    });
  });
}
