import 'package:algorithm_visualizer/core/widgets/custom_widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows the title and the trailing note', (tester) async {
    await pumpApp(tester, const SectionHeader(title: 'Activity', trailing: 'Last 12 weeks'));

    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Last 12 weeks'), findsOneWidget);
  });

  testWidgets('without a note, only the title', (tester) async {
    await pumpApp(tester, const SectionHeader(title: 'Activity'));

    expect(find.byType(Text), findsOneWidget);
  });

  testWidgets('a long title wraps instead of overflowing', (tester) async {
    await pumpApp(
      tester,
      const SectionHeader(title: 'A long section title that fills the whole row', trailing: 'Last 12 weeks'),
      screen: ScreenSize.smallPhone,
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
  });
}
