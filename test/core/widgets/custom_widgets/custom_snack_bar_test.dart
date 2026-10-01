import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<BuildContext> pumpPage(WidgetTester tester) async {
    await pumpApp(tester, const Scaffold(body: SizedBox()));
    return tester.element(find.byType(SizedBox).last);
  }

  for (final (type, icon, color) in [
    (CustomSnackBarType.error, Icons.error_outline_rounded, ThemeEnum.dataHard),
    (CustomSnackBarType.success, Icons.check_circle_outline_rounded, ThemeEnum.dataEasy),
    (CustomSnackBarType.warning, Icons.warning_amber_rounded, ThemeEnum.dataMedium),
    (CustomSnackBarType.info, Icons.info_outline_rounded, ThemeEnum.inkSecondaryTitle),
  ]) {
    testWidgets('${type.name} has its own icon and colour', (tester) async {
      final context = await pumpPage(tester);

      context.showSnackBar(message: 'Saved', type: type);
      await tester.pumpAndSettle();

      expect(find.text('Saved'), findsOneWidget);
      final leading = tester.widget<CustomIcon>(find.byType(CustomIcon).first);
      expect(leading.icon, icon);
      expect(leading.color, color);
      await tester.pump(const Duration(seconds: 4));
    });
  }

  testWidgets('a new message replaces the one showing', (tester) async {
    final context = await pumpPage(tester);

    context.showSnackBar(message: 'First', type: CustomSnackBarType.info);
    await tester.pumpAndSettle();
    context.showSnackBar(message: 'Second', type: CustomSnackBarType.info);
    await tester.pumpAndSettle();

    expect(find.text('First'), findsNothing);
    expect(find.text('Second'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('it goes away by itself after three seconds', (tester) async {
    final context = await pumpPage(tester);

    context.showSnackBar(message: 'Saved', type: CustomSnackBarType.success);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Saved'), findsNothing);
  });

  testWidgets('tapping it, or hiding it from code, closes it', (tester) async {
    final context = await pumpPage(tester);

    context.showSnackBar(message: 'Saved', type: CustomSnackBarType.success);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsNothing);

    context.showSnackBar(message: 'Again', type: CustomSnackBarType.success);
    await tester.pumpAndSettle();
    context.hideCurrentSnackBar();
    await tester.pumpAndSettle();
    expect(find.text('Again'), findsNothing);
  });
}
