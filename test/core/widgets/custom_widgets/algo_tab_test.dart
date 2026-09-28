import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/algo_tab.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Color? labelColor(WidgetTester tester) => tester.widget<Text>(find.text('Sorting')).style!.color;
  Color colorOf(WidgetTester tester, ThemeEnum role) => tester.element(find.text('Sorting')).getColor(role);

  group('the main tab', () {
    testWidgets('selected reads in the title ink, unselected in the secondary', (tester) async {
      Widget tab({required bool selected}) =>
          Center(child: MainAlgoTab(label: 'Sorting', isSelected: selected, addEndPadding: false));

      await pumpApp(tester, tab(selected: true));
      expect(labelColor(tester), colorOf(tester, ThemeEnum.inkTitle));

      await pumpApp(tester, tab(selected: false));
      expect(labelColor(tester), colorOf(tester, ThemeEnum.inkSecondaryTitle));
    });
  });

  group('the algorithm tab', () {
    testWidgets('selected reads on the fill, with its icon', (tester) async {
      await pumpApp(
        tester,
        const Center(
          child: AlgoTab(
            label: 'Sorting',
            icon: Icons.bar_chart_rounded,
            isSelected: true,
            addEndPadding: false,
          ),
        ),
      );

      expect(labelColor(tester), colorOf(tester, ThemeEnum.ground));
      expect(tester.widget<CustomIcon>(find.byType(CustomIcon)).color, ThemeEnum.ground);
    });

    testWidgets('unselected, and with no icon', (tester) async {
      const tab = AlgoTab(label: 'Sorting', isSelected: false, addEndPadding: false);
      await pumpApp(tester, const Center(child: tab));

      expect(labelColor(tester), colorOf(tester, ThemeEnum.inkSecondaryTitle));
      expect(find.byType(CustomIcon), findsNothing);
    });

    testWidgets('a long label shrinks to fit a narrow tab instead of overflowing', (tester) async {
      await pumpApp(
        tester,
        const Center(
          child: SizedBox(
            width: 80,
            child: AlgoTab(
              label: 'Selection Sort',
              icon: Icons.sort_rounded,
              isSelected: true,
              addEndPadding: false,
            ),
          ),
        ),
        textScale: 2,
      );

      expect(tester.takeException(), isNull);
    });
  });
}
