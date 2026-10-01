import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/helpers/storage/app_settings/app_settings_cubit.dart';
import 'package:algorithm_visualizer/core/helpers/system_overlay_style.dart';
import 'package:algorithm_visualizer/core/material_app/my_app.dart';
import 'package:algorithm_visualizer/features/home/view/home_page.dart';
import 'package:algorithm_visualizer/features/onboarding/view/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_launch.dart';

void main() {
  setUpLaunch(onboardingSeen: true);

  ThemeMode appThemeMode(WidgetTester tester) =>
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode!;
  bool darkBars(WidgetTester tester) => tester.widget<SystemOverlay>(find.byType(SystemOverlay)).isBlackTheme;

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('after onboarding, the app opens on home', (tester) async {
    await pumpLaunch(tester, const MyApp());
    await settle(tester);

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(OnboardingPage), findsNothing);
  });

  testWidgets('a dark theme saved earlier is in force, bars included', (tester) async {
    await pumpLaunch(tester, const MyApp(), theme: ThemeMode.dark);
    await settle(tester);

    expect(appThemeMode(tester), ThemeMode.dark);
    expect(darkBars(tester), isTrue);
  });

  testWidgets('a light theme saved earlier gives light bars even on a dark phone', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await pumpLaunch(tester, const MyApp(), theme: ThemeMode.light);
    await settle(tester);

    expect(appThemeMode(tester), ThemeMode.light);
    expect(darkBars(tester), isFalse);
  });

  for (final brightness in Brightness.values) {
    testWidgets('with no choice saved, the bars follow a ${brightness.name} phone', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await pumpLaunch(tester, const MyApp());
      await settle(tester);

      expect(appThemeMode(tester), ThemeMode.system);
      expect(darkBars(tester), brightness == Brightness.dark);
    });
  }

  testWidgets('changing the theme applies at once', (tester) async {
    final container = await pumpLaunch(tester, const MyApp(), theme: ThemeMode.light);
    await settle(tester);

    await container.read(appSettingsProvider.notifier).changeTheme(ThemeMode.dark);
    await tester.pump();

    expect(appThemeMode(tester), ThemeMode.dark);
    expect(darkBars(tester), isTrue);
  });

  testWidgets('an address the app does not know shows the unknown page', (tester) async {
    await pumpLaunch(tester, const MyApp());
    await settle(tester);

    AppRoutes.instance.routerProvider.go('/no-such-page');
    await settle(tester);

    expect(find.byType(UnknownView), findsOneWidget);

    AppRoutes.instance.routerProvider.go(Routes.home.path);
    await settle(tester);
  });
}
