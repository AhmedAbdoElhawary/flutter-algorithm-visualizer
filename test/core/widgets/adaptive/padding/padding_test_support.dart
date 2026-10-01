import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

/// Pumps [padding] around a box in [direction], and returns the edges it ends up with on screen.
/// On the test phone the design size is the screen size, so `10.r` is exactly 10.
Future<EdgeInsets> paddingOnScreen(
  WidgetTester tester,
  Widget Function(Widget child) padding, {
  TextDirection direction = TextDirection.ltr,
}) async {
  const box = SizedBox(key: ValueKey('box'), width: 10, height: 10);
  await pumpApp(tester, Directionality(textDirection: direction, child: Center(child: padding(box))));

  final widget = tester.widget<Padding>(
    find.ancestor(of: find.byKey(const ValueKey('box')), matching: find.byType(Padding)).first,
  );
  return widget.padding.resolve(direction);
}
