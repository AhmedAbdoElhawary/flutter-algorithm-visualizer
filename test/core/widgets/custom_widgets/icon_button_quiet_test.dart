import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/icon_button_quiet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  ThemeEnum? iconColor(WidgetTester tester) => tester.widget<CustomIcon>(find.byType(CustomIcon)).color;

  testWidgets('takes taps, at the size it is given', (tester) async {
    var taps = 0;
    final button = IconButtonQuiet(icon: Icons.play_arrow_rounded, onTap: () => taps++, size: 44);
    await pumpApp(tester, Center(child: button));

    await tester.tap(find.byType(IconButtonQuiet));

    expect(taps, 1);
    expect(tester.getSize(find.byType(IconButtonQuiet)), const Size(44, 44));
  });

  testWidgets('outlined by default, in the secondary ink', (tester) async {
    await pumpApp(tester, IconButtonQuiet(icon: Icons.pause_rounded, onTap: () {}));

    expect(iconColor(tester), ThemeEnum.inkSecondaryTitle);
  });

  testWidgets('filled, the icon takes the page colour', (tester) async {
    await pumpApp(tester, IconButtonQuiet(icon: Icons.play_arrow_rounded, onTap: () {}, filled: true));

    expect(iconColor(tester), ThemeEnum.ground);
  });

  testWidgets('with no action, the icon fades to the track colour', (tester) async {
    await pumpApp(tester, const IconButtonQuiet(icon: Icons.pause_rounded));

    expect(iconColor(tester), ThemeEnum.track);
  });

  testWidgets('a given icon colour always wins', (tester) async {
    await pumpApp(tester, const IconButtonQuiet(icon: Icons.logout_rounded, iconColor: ThemeEnum.dataHard));

    expect(iconColor(tester), ThemeEnum.dataHard);
  });
}
