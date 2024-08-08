part of 'app_settings_cubit.dart';

class AppSettingsState {
  final LanguagesEnum language;
  final ThemeMode themeMode;

  AppSettingsState({required this.language, required this.themeMode});

  factory AppSettingsState.initial() {
    return AppSettingsState(
      language: LanguagesEnum.english,
      themeMode: ThemeMode.light,
    );
  }

  AppSettingsState copyWith({LanguagesEnum? language, ThemeMode? themeMode}) {
    return AppSettingsState(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
