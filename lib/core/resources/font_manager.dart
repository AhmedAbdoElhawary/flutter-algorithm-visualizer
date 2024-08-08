import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// class CustomGoogleFont {
//   static TextStyle getFontStyle({required TextStyle textStyle}) {
//     return textStyle.copyWith(fontWeight: FontWeight.w100);
//   }
//
//   static TextTheme getFontTextTheme(TextTheme textTheme) {
//     return textTheme;
//   }
// }

class FontConstants {
  static const String fontFamily = "Sf_UI_Display";
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

  static FontWeight getAdaptiveFontWeight(FontWeight oldWeight) {
    if (oldWeight == light100) return light200;
    if (oldWeight == light200) return light;
    if (oldWeight == light) return regular;
    if (oldWeight == regular) return medium;
    if (oldWeight == medium) return semiBold;
    if (oldWeight == semiBold) return bold;
    if (oldWeight == bold) return bold800;
    if (oldWeight == bold800) return bold900;
    return oldWeight;
  }
}
