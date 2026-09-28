import 'package:algorithm_visualizer/core/widgets/custom_widgets/problem_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  final border = find.descendant(of: find.byType(ProblemRow), matching: find.byType(IgnorePointer));

  testWidgets('a plain row shows its content and takes no taps', (tester) async {
    await pumpApp(tester, const ProblemRow(child: Text('Two Sum')));

    expect(find.text('Two Sum'), findsOneWidget);
    expect(find.byType(GestureDetector), findsNothing);
    expect(border, findsNothing);
  });

  testWidgets('taps and long presses reach the row', (tester) async {
    var taps = 0;
    var longPresses = 0;
    await pumpApp(
      tester,
      ProblemRow(onTap: () => taps++, onLongTap: () => longPresses++, child: const Text('Two Sum')),
    );

    await tester.tap(find.text('Two Sum'));
    await tester.longPress(find.text('Two Sum'));

    expect(taps, 1);
    expect(longPresses, 1);
  });

  testWidgets('a selected row draws its stronger border without blocking taps', (tester) async {
    var taps = 0;
    await pumpApp(tester, ProblemRow(selected: true, onTap: () => taps++, child: const Text('Two Sum')));

    await tester.tap(find.text('Two Sum'));

    expect(border, findsOneWidget);
    expect(taps, 1);
  });
}
