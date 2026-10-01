import 'package:algorithm_visualizer/features/settings/widgets/settings_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/screen_matrix.dart';

void main() {
  Future<void> pumpRow(WidgetTester tester, SettingsRow row, {ScreenVariant? variant}) => pumpApp(
        tester,
        Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: row)),
        screen: variant?.screen ?? ScreenSize.phone,
        theme: variant?.theme ?? ThemeMode.light,
        textScale: variant?.textScale ?? 1.0,
      );

  testScreenMatrix('a long title and caption fit the screen', (tester, variant) async {
    await pumpRow(
      tester,
      SettingsRow(icon: Icons.info_outline, title: 'Title ' * 12, subtitle: 'Caption ' * 30),
      variant: variant,
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the title, the caption and a chevron', (tester) async {
    await pumpRow(tester, const SettingsRow(icon: Icons.info_outline, title: 'Title', subtitle: 'Caption'));

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Caption'), findsOneWidget);
    expect(find.byKey(SettingsRow.chevronKey), findsOneWidget);
  });

  testWidgets('an empty caption is left out', (tester) async {
    await pumpRow(tester, const SettingsRow(icon: Icons.info_outline, title: 'Title', subtitle: ''));

    expect(find.text(''), findsNothing);
  });

  testWidgets('a trailing widget replaces the chevron, and the chevron can be turned off', (tester) async {
    await pumpRow(
      tester,
      const SettingsRow(icon: Icons.info_outline, title: 'Title', trailing: SizedBox(key: ValueKey('trailing'))),
    );
    expect(find.byKey(const ValueKey('trailing')), findsOneWidget);
    expect(find.byKey(SettingsRow.chevronKey), findsNothing);

    await pumpRow(tester, const SettingsRow(icon: Icons.info_outline, title: 'Title', showChevron: false));
    expect(find.byKey(SettingsRow.chevronKey), findsNothing);
  });

  testWidgets('a tap anywhere on the row calls onTap', (tester) async {
    var taps = 0;
    await pumpRow(tester, SettingsRow(icon: Icons.info_outline, title: 'Title', onTap: () => taps++));

    await tester.tap(find.byType(SettingsRow));
    await tester.tap(find.text('Title'));

    expect(taps, 2);
  });

  testWidgets('the divider draws', (tester) async {
    await pumpApp(tester, const Scaffold(body: SettingsRowDivider()));

    expect(find.byType(Divider), findsOneWidget);
  });
}
