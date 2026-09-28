import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'padding_test_support.dart';

void main() {
  Widget pad(Widget child) => OnlyPadding(
        startPadding: 1,
        endPadding: 2,
        topPadding: 3,
        bottomPadding: 4,
        child: child,
      );

  testWidgets('left to right', (tester) async {
    expect(await paddingOnScreen(tester, pad), const EdgeInsets.fromLTRB(1, 3, 2, 4));
  });

  testWidgets('right to left mirrors it', (tester) async {
    final edges = await paddingOnScreen(tester, pad, direction: TextDirection.rtl);

    expect(edges, const EdgeInsets.fromLTRB(2, 3, 1, 4));
  });
}
