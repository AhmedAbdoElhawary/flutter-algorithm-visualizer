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
}

extension LanguagesString on String {
  LanguagesEnum get language => _keys[this] ?? LanguagesEnum.english;

  Map<String, LanguagesEnum> get _keys => {
        "en": LanguagesEnum.english,
        "ar": LanguagesEnum.arabic,
      };
}
