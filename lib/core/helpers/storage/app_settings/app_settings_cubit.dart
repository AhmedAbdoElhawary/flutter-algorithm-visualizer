import 'package:algorithm_visualizer/core/enums/app_settings_enum.dart';
import 'package:algorithm_visualizer/core/extensions/language.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:get_storage/get_storage.dart';

part 'app_settings_state.dart';

// Define your StateNotifierProvider
final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettingsState>(
        (ref) => AppSettingsNotifier());

class AppSettingsNotifier extends StateNotifier<AppSettingsState> {
  AppSettingsNotifier() : super(AppSettingsState.initial());

  static String getStorageKey = "AppSettings";
  final String _langSveKey = "lang";
  final String _modeSveKey = "mode";
  String? _languageSelectedChar;
  ThemeMode? _selectedMode;

  // Use GetStorage instance
  final GetStorage _storage = GetStorage(getStorageKey);

  LanguagesEnum get languageSelected => languageSelectedChar.language;

  String get languageSelectedChar =>
      _languageSelectedChar ?? _getLanguageSelectedChar;
  String get _getLanguageSelectedChar => _storage.read(_langSveKey) ?? "en";

  bool get isLangEnglish => languageSelected == LanguagesEnum.english;

  Future<void> _saveLanguageToDisk(String lang) async {
    await _storage.write(_langSveKey, lang);
    if (_getLanguageSelectedChar != lang) throw "unable to change language";
  }

  Future<bool> changeLanguage(LanguagesEnum lang) async {
    if (lang == languageSelected) return false;

    try {
      await Future.wait([
        _saveLanguageToDisk(lang.shortKey),
        // initializeDateFormatting(lang.shortKey, null),
      ]);

      state = state.copyWith(language: lang);

      _languageSelectedChar = lang.shortKey;

      return true;
    } catch (e) {
      _languageSelectedChar = null;

      rethrow;
    }
  }

  Future<void> _saveModeToDisk(String mode) async {
    await _storage.write(_modeSveKey, mode);
    if (_getModeSelected.name != mode) throw "unable to change the mode";
    _selectedMode = _getModeSelected;
  }

  Future<void> changeTheme(ThemeMode mode) async {
    if (mode == modeSelected) return;
    try {
      await _saveModeToDisk(mode.name);
      // final isLight = mode.name == 'light';
      //
      // if (isLight) {
      //   Get.changeThemeMode(ThemeMode.light);
      // } else {
      //   Get.changeThemeMode(ThemeMode.dark);
      // }
      state = state.copyWith(themeMode: mode);
    } catch (e) {
      _selectedMode = null;
      rethrow;
    }
  }

  ThemeMode get modeSelected => _selectedMode ?? _getModeSelected;

  ThemeMode get _getModeSelected =>
      (_storage.read(_modeSveKey) ?? "light") == "light"
          ? ThemeMode.light
          : ThemeMode.dark;

  bool get isThemeLight => modeSelected == ThemeMode.light;
}
