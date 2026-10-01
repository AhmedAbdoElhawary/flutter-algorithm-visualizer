import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/heat_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  List<Color?> cellColors(WidgetTester tester, Finder within) => tester
      .widgetList<Container>(find.descendant(of: within, matching: find.byType(Container)))
      .map((cell) => (cell.decoration! as BoxDecoration).color)
      .toList();

  testWidgets('one cell per day, each in its level, out-of-range levels clamped', (tester) async {
    await pumpApp(tester, const HeatGrid(dailyCounts: [0, 1, 2, 3, 4, 9, -2]));
    final context = tester.element(find.byType(HeatGrid));
    Color level(int i) => context.getColor(HeatGrid.heatLevels[i]);

    expect(cellColors(tester, find.byType(HeatGrid)), [
      level(0),
      level(1),
      level(2),
      level(3),
      level(4),
      level(4),
      level(0),
    ]);
  });

  testWidgets('only an empty day gets an outline, so it still shows on the page', (tester) async {
    await pumpApp(tester, const HeatGrid(dailyCounts: [0, 3]));

    final cells = tester.widgetList<Container>(
      find.descendant(of: find.byType(HeatGrid), matching: find.byType(Container)),
    );
    expect(cells.map((cell) => (cell.decoration! as BoxDecoration).border != null), [true, false]);
  });

  testWidgets('the legend runs from less to more through the same levels', (tester) async {
    await pumpApp(tester, const Center(child: HeatGridLegend()));
    final context = tester.element(find.byType(HeatGridLegend));

    expect(find.text(StringsManager.less), findsOneWidget);
    expect(find.text(StringsManager.more), findsOneWidget);
    final levels = HeatGrid.heatLevels.map(context.getColor).toList();
    expect(cellColors(tester, find.byType(HeatGridLegend)), levels);
  });
}
