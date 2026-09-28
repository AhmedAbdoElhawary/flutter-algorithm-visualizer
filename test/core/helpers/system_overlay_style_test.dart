import 'package:algorithm_visualizer/core/helpers/system_overlay_style.dart';
import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SystemUiOverlayStyle styleOf(WidgetTester tester) =>
      tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(find.byType(AnnotatedRegion<SystemUiOverlayStyle>)).value;

  testWidgets('dark: the bars match the dark page, with light icons', (tester) async {
    await tester.pumpWidget(const SystemOverlay(child: SizedBox()));

    final style = styleOf(tester);
    expect(style.statusBarColor, ColorManager.groundDk);
    expect(style.systemNavigationBarColor, ColorManager.groundDk);
    expect(style.statusBarIconBrightness, Brightness.light);
    expect(style.systemNavigationBarIconBrightness, Brightness.light);
  });

  testWidgets('light: the bars match the light page, with dark icons', (tester) async {
    await tester.pumpWidget(const SystemOverlay(isBlackTheme: false, child: SizedBox()));

    final style = styleOf(tester);
    expect(style.statusBarColor, ColorManager.groundLt);
    expect(style.systemNavigationBarColor, ColorManager.groundLt);
    expect(style.statusBarIconBrightness, Brightness.dark);
    expect(style.systemNavigationBarIconBrightness, Brightness.dark);
  });
}
