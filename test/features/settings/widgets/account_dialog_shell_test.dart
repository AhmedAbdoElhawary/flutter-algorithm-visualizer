import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/settings/widgets/account_dialog_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  var cancels = 0;
  var confirms = 0;

  setUp(() {
    cancels = 0;
    confirms = 0;
  });

  Future<void> pumpShell(WidgetTester tester, {bool loading = false}) => pumpApp(
        tester,
        Scaffold(
          body: Center(
            child: AccountDialogShell(
              icon: Icons.lock_outline,
              title: 'Title',
              description: 'Description',
              fields: const [Text('field')],
              confirmLabel: 'Confirm',
              loading: loading,
              onCancel: () => cancels++,
              onConfirm: () => confirms++,
            ),
          ),
        ),
      );

  testWidgets('shows the title, the description and the fields', (tester) async {
    await pumpShell(tester);

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('field'), findsOneWidget);
  });

  testWidgets('cancel and confirm call back', (tester) async {
    await pumpShell(tester);

    await tester.tap(find.text(StringsManager.cancel));
    await tester.tap(find.text('Confirm'));

    expect((cancels, confirms), (1, 1));
  });

  testWidgets('while loading neither button does anything', (tester) async {
    await pumpShell(tester, loading: true);

    await tester.tap(find.text(StringsManager.cancel));
    await tester.pump();

    expect((cancels, confirms), (0, 0));
  });
}
