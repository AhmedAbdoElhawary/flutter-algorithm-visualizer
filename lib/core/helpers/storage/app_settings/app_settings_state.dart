part of 'app_settings_cubit.dart';

class AppSettingsState {
  final LanguagesEnum language;
  final ThemeMode themeMode;

  const AppSettingsState({required this.language, required this.themeMode});

  /// Only for callers that have no storage to read — tests, and the default
  /// any parse failure lands on. A real launch builds this from disk in
  /// [AppSettingsNotifier.build].
  factory AppSettingsState.initial() {
    return const AppSettingsState(
      language: LanguagesEnum.english,
      themeMode: ThemeMode.system,
    );
  }

  AppSettingsState copyWith({LanguagesEnum? language, ThemeMode? themeMode}) {
    return AppSettingsState(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsState &&
          runtimeType == other.runtimeType &&
          language == other.language &&
          themeMode == other.themeMode;

  @override
  int get hashCode => Object.hash(language, themeMode);
}
