import 'package:flutter/material.dart';

class FontConstants {
  /// CoreDive UI family. Bundled as an asset font (see pubspec.yaml,
  /// assets/fonts/ibm_plex_sans_arabic/); this string is the family name
  /// registered there. Prefer leaving a style's `fontFamily` null so it
  /// inherits this from the theme.
  static const String fontFamily = "IBM Plex Sans Arabic";

  /// Legacy bundled mono, also loaded as an asset font.
  static const String fontJetBrainsMono = fontFamily;
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
