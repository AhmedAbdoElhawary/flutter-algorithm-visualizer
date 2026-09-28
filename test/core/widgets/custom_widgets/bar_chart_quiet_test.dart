import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/bar_chart_quiet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('a bar has its size and colour, and grows smoothly when its height changes', (tester) async {
    await pumpApp(tester, const Center(child: QuietBar(width: 6, height: 10, fill: ThemeEnum.dataEasy)));
    expect(tester.getSize(find.byType(QuietBar)), const Size(6, 10));

    await pumpApp(tester, const Center(child: QuietBar(width: 6, height: 30, fill: ThemeEnum.dataEasy)));
    await tester.pump(const Duration(milliseconds: 50));
    final halfway = tester.getSize(find.byType(QuietBar)).height;
    await tester.pumpAndSettle();

    expect(halfway, inExclusiveRange(10, 30));
    expect(tester.getSize(find.byType(QuietBar)).height, 30);
    final box = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).decoration! as BoxDecoration;
    expect(box.color, tester.element(find.byType(QuietBar)).getColor(ThemeEnum.dataEasy));
  });
}
