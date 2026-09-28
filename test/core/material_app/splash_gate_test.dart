import 'package:algorithm_visualizer/core/material_app/my_app.dart';
import 'package:algorithm_visualizer/core/material_app/splash_gate.dart';
import 'package:algorithm_visualizer/core/widgets/splash/algodive_splash.dart';
import 'package:algorithm_visualizer/features/home/view/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_launch.dart';

void main() {
  setUpLaunch(onboardingSeen: true);

  testWidgets('the splash plays first, then hands over to the app', (tester) async {
    await pumpLaunch(tester, const SplashGate());

    expect(find.byType(AlgoDiveSplash), findsOneWidget);
    expect(find.byType(MyApp), findsNothing);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(AlgoDiveSplash), findsNothing);
    expect(find.byType(HomePage), findsOneWidget);
  });

  for (final brightness in Brightness.values) {
    testWidgets('the splash matches a ${brightness.name} phone', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await pumpLaunch(tester, const SplashGate());

      expect(tester.widget<AlgoDiveSplash>(find.byType(AlgoDiveSplash)).dark, brightness == Brightness.dark);
      await tester.pump(const Duration(seconds: 3));
    });
  }
}
