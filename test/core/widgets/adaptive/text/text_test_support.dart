import 'package:algorithm_visualizer/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

/// Pumps [text], in Arabic when [arabic] is set, and returns the `Text` it draws.
Future<Text> textOnScreen(
  WidgetTester tester,
  Widget text, {
  bool arabic = false,
  ThemeMode theme = ThemeMode.light,
}) async {
  await pumpApp(
    tester,
    Material(
      child: Builder(
        builder: (context) => arabic
            ? Localizations.override(
                context: context,
                locale: const Locale('ar'),
                delegates: const [AppLocalizations.delegate],
                child: text,
              )
            : text,
      ),
    ),
    theme: theme,
  );
  return tester.widget<Text>(find.byType(Text));
}
