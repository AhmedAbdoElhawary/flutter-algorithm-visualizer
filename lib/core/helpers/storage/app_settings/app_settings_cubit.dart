import 'package:algorithm_visualizer/core/enums/app_settings_enum.dart';
import 'package:algorithm_visualizer/core/extensions/language.dart';
import 'package:algorithm_visualizer/core/storage/storage.dart';
import 'package:algorithm_visualizer/core/storage/storage_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_settings_state.dart';

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettingsState>(() => AppSettingsNotifier());

/// Device-level preferences: which language, and which theme.
///
/// Both are read back **in [build]**, not defaulted there. An earlier version
/// returned a hard-coded initial state and only ever consulted disk from
/// separate getters nothing watched, so a preference the user had saved was
/// silently ignored on the next launch.
class AppSettingsNotifier extends Notifier<AppSettingsState> {
  late final LocalStorage _storage;

  static const String languageKey = 'lang';
  static const String themeModeKey = 'mode';

  @override
  AppSettingsState build() {
    _storage = ref.watch(appSettingsStorageProvider);

    return AppSettingsState(
      language: _readLanguage(),
      themeMode: _readThemeMode(),
    );
  }

  // ---------------------------------------------------------------- language

  LanguagesEnum _readLanguage() => (_storage.read<String>(languageKey) ?? 'en').language;

  LanguagesEnum get languageSelected => state.language;

  bool get isLangEnglish => state.language == LanguagesEnum.english;

  /// Returns whether anything actually changed, so a caller can skip work when
  /// the user re-picks what was already selected.
  Future<bool> changeLanguage(LanguagesEnum language) async {
    if (language == state.language) return false;

    await _storage.write(languageKey, language.shortKey);
    state = state.copyWith(language: language);
    return true;
  }

  // ------------------------------------------------------------------- theme

  /// Unrecognised or absent values fall back to [ThemeMode.system] — a fresh
  /// install should look like the rest of the phone before it looks like
  /// anyone's preference.
  ThemeMode _readThemeMode() {
    final stored = _storage.read<String>(themeModeKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  ThemeMode get modeSelected => state.themeMode;

  Future<bool> changeTheme(ThemeMode mode) async {
    if (mode == state.themeMode) return false;

    await _storage.write(themeModeKey, mode.name);
    state = state.copyWith(themeMode: mode);
    return true;
  }
}
