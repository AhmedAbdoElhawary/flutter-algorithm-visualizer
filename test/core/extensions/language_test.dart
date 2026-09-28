import 'package:algorithm_visualizer/core/enums/app_settings_enum.dart';
import 'package:algorithm_visualizer/core/extensions/language.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each language has its short key, and the key reads back to it', () {
    expect(LanguagesEnum.english.shortKey, 'en');
    expect(LanguagesEnum.arabic.shortKey, 'ar');
    for (final language in LanguagesEnum.values) {
      expect(language.shortKey.language, language);
    }
  });

  test('an unknown or empty key falls back to English', () {
    expect('fr'.language, LanguagesEnum.english);
    expect(''.language, LanguagesEnum.english);
  });

  test('each language is named in itself, with its name in the other language as the hint', () {
    expect(LanguagesEnum.english.nativeName, 'English');
    expect(LanguagesEnum.arabic.nativeName, 'العربية');
    expect(LanguagesEnum.english.endonymHint, 'الإنجليزية');
    expect(LanguagesEnum.arabic.endonymHint, 'Arabic');
  });
}
