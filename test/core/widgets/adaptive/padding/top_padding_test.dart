import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'padding_test_support.dart';

void main() {
  Widget pad(Widget child) => TopPadding(padding: 8, child: child);

  for (final direction in TextDirection.values) {
    testWidgets('the same edges in ${direction.name}', (tester) async {
      final edges = await paddingOnScreen(tester, pad, direction: direction);

      expect(edges, const EdgeInsets.only(top: 8));
    });
  }
}
