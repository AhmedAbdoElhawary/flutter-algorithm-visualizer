import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/stat_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Color? valueColor(WidgetTester tester) => tester.widget<Text>(find.text('12')).style!.color;

  testWidgets('shows the value and its label, with no header row by default', (tester) async {
    await pumpApp(tester, const StatTile(label: 'Solved', value: '12'));

    expect(find.text('Solved'), findsOneWidget);
    expect(find.byType(Icon), findsNothing);
    expect(valueColor(tester), tester.element(find.text('12')).getColor(ThemeEnum.inkTitle));
  });

  testWidgets('an icon and a note make a header row', (tester) async {
    const tile = StatTile(label: 'Solved', value: '12', icon: Icons.check_rounded, sub: 'of 40');
    await pumpApp(tester, tile);

    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.text('of 40'), findsOneWidget);
  });

  testWidgets('an empty note is left out', (tester) async {
    await pumpApp(tester, const StatTile(label: 'Solved', value: '12', sub: ''));

    expect(find.byType(Text), findsNWidgets(2));
  });

  testWidgets('an emphasized tile shows the value in the primary ink, with a border', (tester) async {
    await pumpApp(tester, const StatTile(label: 'Streak', value: '12', emphasized: true));

    expect(valueColor(tester), tester.element(find.text('12')).getColor(ThemeEnum.inkPrimary));
    expect(find.descendant(of: find.byType(StatTile), matching: find.byType(IgnorePointer)), findsOneWidget);
  });
}
