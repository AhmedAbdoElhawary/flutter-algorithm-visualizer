import 'package:algorithm_visualizer/core/enums/app_settings_enum.dart';
import 'package:algorithm_visualizer/core/helpers/storage/app_settings/app_settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const arabicDark = AppSettingsState(language: LanguagesEnum.arabic, themeMode: ThemeMode.dark);

  test('the initial state is English, following the phone theme', () {
    expect(
      AppSettingsState.initial(),
      const AppSettingsState(language: LanguagesEnum.english, themeMode: ThemeMode.system),
    );
  });

  test('copyWith changes only what it is given', () {
    expect(arabicDark.copyWith(), arabicDark);
    expect(arabicDark.copyWith(themeMode: ThemeMode.light).language, LanguagesEnum.arabic);
    expect(arabicDark.copyWith(language: LanguagesEnum.english).themeMode, ThemeMode.dark);
  });

  test('equal states are equal and hash the same, different ones are not', () {
    const same = AppSettingsState(language: LanguagesEnum.arabic, themeMode: ThemeMode.dark);

    expect(same, arabicDark);
    expect(same.hashCode, arabicDark.hashCode);
    expect(arabicDark.copyWith(themeMode: ThemeMode.light), isNot(arabicDark));
    expect(arabicDark.copyWith(language: LanguagesEnum.english), isNot(arabicDark));
  });
}
