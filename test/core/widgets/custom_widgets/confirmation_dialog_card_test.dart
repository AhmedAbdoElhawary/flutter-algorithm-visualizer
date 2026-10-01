import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/confirmation_dialog_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/screen_matrix.dart';

void main() {
  ConfirmationDialogCard card({VoidCallback? onConfirm, VoidCallback? onCancel}) => ConfirmationDialogCard(
        icon: Icons.delete_outline_rounded,
        title: 'Delete account?',
        description: 'This removes your progress and cannot be undone.',
        confirmLabel: 'Delete',
        onConfirm: onConfirm ?? () {},
        onCancel: onCancel ?? () {},
      );

  testWidgets('shows the question and both answers, each doing its own thing', (tester) async {
    final answers = <String>[];
    await pumpApp(
      tester,
      Center(child: card(onConfirm: () => answers.add('confirm'), onCancel: () => answers.add('cancel'))),
    );

    expect(find.text('Delete account?'), findsOneWidget);
    expect(find.text('This removes your progress and cannot be undone.'), findsOneWidget);

    await tester.tap(find.text(StringsManager.cancel));
    await tester.tap(find.text('Delete'));

    expect(answers, ['cancel', 'confirm']);
  });

  testScreenMatrix('fits the screen', (tester, variant) async {
    await pumpApp(
      tester,
      Center(child: card()),
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );

    expect(tester.takeException(), isNull);
  });
}
