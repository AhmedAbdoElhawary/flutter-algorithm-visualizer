import 'package:algorithm_visualizer/core/widgets/custom_widgets/empty_state_quiet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows the title and the caption, inside a dashed border', (tester) async {
    const empty = EmptyStateQuiet(title: 'No bookmarks yet', caption: 'Tap the flag on a problem');
    await pumpApp(tester, empty);

    expect(find.text('No bookmarks yet'), findsOneWidget);
    expect(find.text('Tap the flag on a problem'), findsOneWidget);
    final border = find.descendant(of: find.byType(EmptyStateQuiet), matching: find.byType(CustomPaint));
    expect(border, findsOneWidget);
  });

  testWidgets('without a caption, only the title', (tester) async {
    await pumpApp(tester, const EmptyStateQuiet(title: 'No bookmarks yet'));

    expect(find.byType(Text), findsOneWidget);
  });

}
