import 'package:algorithm_visualizer/core/enums/app_settings_enum.dart';
import 'package:algorithm_visualizer/core/extensions/language.dart';
import 'package:algorithm_visualizer/core/helpers/storage/app_settings/app_settings_cubit.dart';
import 'package:algorithm_visualizer/core/storage/storage_providers.dart';
import 'package:algorithm_visualizer/features/settings/widgets/settings_language_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/screen_matrix.dart';

// Parked until Arabic is reachable (see the TODO in settings_page.dart); tested so it still works when it returns.
void main() {
  testScreenMatrix('names each language in its own script and fits the screen', (tester, variant) async {
    await pumpApp(
      tester,
      const Scaffold(body: SettingsLanguageSection()),
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );

    for (final language in LanguagesEnum.values) {
      expect(find.text(language.nativeName), findsOneWidget, reason: language.name);
      expect(find.text(language.endonymHint), findsOneWidget, reason: language.name);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('picking a language saves it and switches the app', (tester) async {
    final container = await pumpApp(tester, const Scaffold(body: SettingsLanguageSection()));

    await tester.tap(find.text(LanguagesEnum.arabic.nativeName));
    await tester.pump();

    expect(container.read(appSettingsProvider).language, LanguagesEnum.arabic);
    expect(
      container.read(appSettingsStorageProvider).read<String>(AppSettingsNotifier.languageKey),
      LanguagesEnum.arabic.shortKey,
    );
  });
}
