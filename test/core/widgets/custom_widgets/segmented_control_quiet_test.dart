import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/segmented_control_quiet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows every option, marks the chosen one, and reports a tap', (tester) async {
    final picked = <int>[];
    final control =
        SegmentedControlQuiet(labels: const ['1x', '2x', '4x'], selectedIndex: 1, onChanged: picked.add);
    await pumpApp(tester, Center(child: control));

    final chosen = tester.widget<Text>(find.text('2x')).style!.color;
    final other = tester.widget<Text>(find.text('1x')).style!.color;
    final context = tester.element(find.text('2x'));
    expect(chosen, context.getColor(ThemeEnum.inkTitle));
    expect(other, context.getColor(ThemeEnum.inkSecondaryTitle));

    await tester.tap(find.text('4x'));

    expect(picked, [2]);
  });
}
