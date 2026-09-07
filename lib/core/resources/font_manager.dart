import 'package:flutter/material.dart';

class FontConstants {
  /// CoreDive UI family. Loaded at runtime via `google_fonts`
  /// (`GoogleFonts.ibmPlexSansArabicTextTheme` in [AppTheme]); this string is the
  /// canonical family name google_fonts registers it under. Prefer leaving a
  /// style's `fontFamily` null so it inherits this from the theme.
  static const String fontFamily = "IBM Plex Sans Arabic";

  /// Legacy bundled mono. New code uses the CoreDive `mono` scale
  /// (`context.cdText.mono`), which resolves JetBrains Mono through google_fonts.
  static const String fontJetBrainsMono = "JetBrainsMono";
}

class FontWeightManager {
  static const FontWeight light100 = FontWeight.w100;
  static const FontWeight light200 = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight bold800 = FontWeight.w800;
  static const FontWeight bold900 = FontWeight.w900;

}
