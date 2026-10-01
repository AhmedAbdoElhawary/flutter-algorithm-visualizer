import 'package:algorithm_visualizer/config/themes/app_theme.dart';
import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  // The app bar sizes use ScreenUtil, so the themes are read inside a pumped app.
  Future<(ThemeData, ThemeData)> themes(WidgetTester tester) async {
    await pumpApp(tester, const SizedBox());
    return (AppTheme.light, AppTheme.dark);
  }

  testWidgets('each theme has its own brightness and ground', (tester) async {
    final (light, dark) = await themes(tester);

    expect(light.brightness, Brightness.light);
    expect(light.scaffoldBackgroundColor, ColorManager.groundLt);
    expect(light.colorScheme.brightness, Brightness.light);
    expect(dark.brightness, Brightness.dark);
    expect(dark.scaffoldBackgroundColor, ColorManager.groundDk);
    expect(dark.colorScheme.brightness, Brightness.dark);
  });

  testWidgets('text on the surface and on primary uses the ink of the same theme', (tester) async {
    final (light, dark) = await themes(tester);

    expect(light.colorScheme.onSurface, ColorManager.inkTitleLt);
    expect(light.colorScheme.primary, ColorManager.inkPrimaryLt);
    expect(light.colorScheme.onPrimary, ColorManager.groundLt);
    expect(dark.colorScheme.onSurface, ColorManager.inkTitleDk);
    expect(dark.colorScheme.primary, ColorManager.inkPrimaryDk);
    expect(dark.colorScheme.onPrimary, ColorManager.groundDk);
  });

  testWidgets('both use the app font, text styles included', (tester) async {
    final (light, dark) = await themes(tester);

    for (final theme in [light, dark]) {
      expect(theme.textTheme.bodyMedium!.fontFamily, FontConstants.fontFamily);
      expect(theme.textTheme.titleLarge!.fontFamily, FontConstants.fontFamily);
    }
  });

  testWidgets('the app bar blends into the page and titles in the theme ink', (tester) async {
    final (light, dark) = await themes(tester);

    expect(light.appBarTheme.backgroundColor, ColorManager.groundLt);
    expect(light.appBarTheme.elevation, 0);
    expect(light.appBarTheme.iconTheme!.color, ColorManager.inkTitleLt);
    expect(light.appBarTheme.titleTextStyle!.color, ColorManager.inkTitleLt);
    expect(dark.appBarTheme.backgroundColor, ColorManager.groundDk);
    expect(dark.appBarTheme.iconTheme!.color, ColorManager.inkTitleDk);
    expect(dark.appBarTheme.titleTextStyle!.color, ColorManager.inkTitleDk);
  });

  testWidgets('taps leave no highlight in either theme', (tester) async {
    final (light, dark) = await themes(tester);

    expect(light.highlightColor, ColorManager.transparent);
    expect(dark.highlightColor, ColorManager.transparent);
  });
}
