import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  final flipped = find.descendant(of: find.byType(CustomIcon), matching: find.byType(Transform));

  Future<void> pumpIcon(
    WidgetTester tester,
    CustomIcon icon, {
    TextDirection direction = TextDirection.ltr,
  }) =>
      pumpApp(tester, Directionality(textDirection: direction, child: icon));

  testWidgets('draws in the title ink unless given a colour', (tester) async {
    await pumpIcon(tester, const CustomIcon(Icons.star_rounded));
    final context = tester.element(find.byType(Icon));
    expect(tester.widget<Icon>(find.byType(Icon)).color, context.getColor(ThemeEnum.inkTitle));

    await pumpIcon(tester, const CustomIcon(Icons.star_rounded, color: ThemeEnum.dataHard, size: 30));
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.color, context.getColor(ThemeEnum.dataHard));
    expect(icon.size, 30);
  });

  testWidgets('a pointing icon Material does not mirror is flipped in right to left', (tester) async {
    await pumpIcon(
      tester,
      const CustomIcon(Icons.skip_next_rounded, flipsWithDirection: true),
      direction: TextDirection.rtl,
    );

    expect(flipped, findsOneWidget);
  });

  testWidgets('one Material mirrors already is mirrored once, not flipped back', (tester) async {
    await pumpIcon(
      tester,
      const CustomIcon(Icons.chevron_right_rounded, flipsWithDirection: true),
      direction: TextDirection.rtl,
    );

    // The only transform is the Icon's own mirror.
    expect(flipped, findsOneWidget);
    expect(find.descendant(of: find.byType(Icon), matching: find.byType(Transform)), findsOneWidget);
  });

  testWidgets('it stays as is in left to right, and a non-pointing icon never flips', (tester) async {
    await pumpIcon(tester, const CustomIcon(Icons.skip_next_rounded, flipsWithDirection: true));
    expect(flipped, findsNothing);

    await pumpIcon(tester, const CustomIcon(Icons.star_rounded), direction: TextDirection.rtl);
    expect(flipped, findsNothing);
  });
}
