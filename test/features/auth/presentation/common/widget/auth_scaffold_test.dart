import 'package:algorithm_visualizer/features/auth/presentation/common/widget/auth_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows the header above the children', (tester) async {
    await pumpApp(
      tester,
      const AuthScaffold(header: Text('header'), children: [Text('first'), Text('second')]),
    );

    expect(tester.getTopLeft(find.text('header')).dy, lessThan(tester.getTopLeft(find.text('first')).dy));
    expect(find.text('second'), findsOneWidget);
  });

  testWidgets('a form taller than the screen scrolls instead of overflowing', (tester) async {
    await pumpApp(
      tester,
      AuthScaffold(children: [for (var i = 0; i < 40; i++) SizedBox(height: 60, child: Text('row $i'))]),
      screen: ScreenSize.smallPhone,
    );

    await tester.scrollUntilVisible(find.text('row 39'), 300);

    expect(find.text('row 39'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
