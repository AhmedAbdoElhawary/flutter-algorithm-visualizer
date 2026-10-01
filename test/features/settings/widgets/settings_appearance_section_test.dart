import 'package:algorithm_visualizer/core/helpers/storage/app_settings/app_settings_cubit.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/storage/storage_providers.dart';
import 'package:algorithm_visualizer/features/settings/widgets/settings_appearance_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<ProviderContainer> pumpSection(WidgetTester tester) =>
      pumpApp(tester, const Scaffold(body: SettingsAppearanceSection()));

  testWidgets('a fresh install follows the system', (tester) async {
    final container = await pumpSection(tester);

    expect(container.read(appSettingsProvider).themeMode, ThemeMode.system);
  });

  testWidgets('picking a mode saves it and switches the app', (tester) async {
    final container = await pumpSection(tester);
    final storage = container.read(appSettingsStorageProvider);

    for (final (title, mode) in [
      (StringsManager.themeDark, ThemeMode.dark),
      (StringsManager.themeLight, ThemeMode.light),
      (StringsManager.themeSystem, ThemeMode.system),
    ]) {
      await tester.tap(find.text(title));
      await tester.pump();

      expect(container.read(appSettingsProvider).themeMode, mode, reason: title);
      expect(storage.read<String>(AppSettingsNotifier.themeModeKey), mode.name, reason: title);
    }
  });
}
