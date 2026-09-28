import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  final box = find.descendant(of: find.byType(CardContainer), matching: find.byType(Container)).first;
  BoxDecoration decorationOf(WidgetTester tester) =>
      tester.widget<Container>(box).decoration! as BoxDecoration;
  Color colorOf(WidgetTester tester, ThemeEnum role) =>
      tester.element(find.byType(CardContainer)).getColor(role);

  for (final (surface, fill) in [
    (CdSurface.main, ThemeEnum.surface),
    (CdSurface.secondary, ThemeEnum.raised),
    (CdSurface.unColoredFill, ThemeEnum.ground),
    (CdSurface.simpleColored, ThemeEnum.raised),
    (CdSurface.fill, ThemeEnum.inkPrimary),
  ]) {
    testWidgets('${surface.name} is filled with its own colour, with a border', (tester) async {
      await pumpApp(tester, CardContainer(surface: surface, child: const Text('card')));

      expect(decorationOf(tester).color, colorOf(tester, fill));
      expect(decorationOf(tester).border, isNotNull);
    });
  }

  testWidgets('outlined has no fill', (tester) async {
    await pumpApp(tester, const CardContainer(surface: CdSurface.outlined, child: Text('card')));

    expect(decorationOf(tester).color, isNull);
  });

  testWidgets('a given fill and border colour win, and the border can be turned off', (tester) async {
    await pumpApp(
      tester,
      const CardContainer(
        fillColor: ThemeEnum.dataHard,
        borderColorOverride: ThemeEnum.dataEasy,
        child: Text('card'),
      ),
    );
    expect(decorationOf(tester).color, colorOf(tester, ThemeEnum.dataHard));
    expect((decorationOf(tester).border! as Border).top.color, colorOf(tester, ThemeEnum.dataEasy));

    await pumpApp(tester, const CardContainer(showBorder: false, child: Text('card')));
    expect(decorationOf(tester).border, isNull);
  });

  testWidgets('clips its content when asked, and takes taps when given an action', (tester) async {
    var taps = 0;
    await pumpApp(tester, CardContainer(clip: true, onTap: () => taps++, child: const Text('card')));

    await tester.tap(find.text('card'));

    expect(find.byType(ClipRRect), findsOneWidget);
    expect(taps, 1);
  });

  testWidgets('the algorithm card shows the name and its worst time and space', (tester) async {
    await pumpApp(
      tester,
      Center(
        child: SizedBox(
          width: 170,
          height: 140,
          child: AlgorithmGlassCard(
            icon: Icons.sort_rounded,
            algoComplexity: AlgorithmComplexity(
              name: 'Merge Sort',
              bestTimeComplexity: ONotationComplexity.nLogN,
              averageTimeComplexity: ONotationComplexity.nLogN,
              worstTimeComplexity: ONotationComplexity.nLogN,
              spaceComplexity: ONotationComplexity.n,
              stable: true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Merge Sort'), findsOneWidget);
    expect(find.text('O(n log n)'), findsOneWidget);
    expect(find.text('O(n)'), findsOneWidget);
  });
}
