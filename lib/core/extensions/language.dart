import 'package:algorithm_visualizer/core/enums/app_settings_enum.dart';

extension LanguagesKeys on LanguagesEnum {
  String get shortKey => _keys[this] ?? "en";
  String get shortKeyWithCounty => _keysWithCountry[this] ?? "en_us";

  Map<LanguagesEnum, String> get _keys => {
        LanguagesEnum.english: "en",
        LanguagesEnum.arabic: "ar",
      };
  Map<LanguagesEnum, String> get _keysWithCountry => {
        LanguagesEnum.english: "en_us",
        LanguagesEnum.arabic: "ar_sa",
      };

  /// Each language is named **in itself**, never translated.
  ///
  /// This is the one list in the app that must stay readable to someone who
  /// cannot read the current language: a user stuck in Arabic has to be able
  /// to find "English", and a user in English has to recognise "العربية".
  String get nativeName => _nativeNames[this] ?? "English";

  Map<LanguagesEnum, String> get _nativeNames => {
        LanguagesEnum.english: "English",
        LanguagesEnum.arabic: "العربية",
      };

  /// The short caption under [nativeName] — the language's name in the
  /// *other* language, so the row reads the same either way round.
  String get endonymHint => _endonymHints[this] ?? "";

  Map<LanguagesEnum, String> get _endonymHints => {
        LanguagesEnum.english: "الإنجليزية",
        LanguagesEnum.arabic: "Arabic",
      };
}

extension LanguagesString on String {
  LanguagesEnum get language => _keys[this] ?? LanguagesEnum.english;

  Map<String, LanguagesEnum> get _keys => {
        "en": LanguagesEnum.english,
        "ar": LanguagesEnum.arabic,
      };
}
