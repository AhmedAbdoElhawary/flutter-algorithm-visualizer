import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/styles_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  /// IBM Plex Sans Arabic, loaded at runtime by google_fonts. One family for
  /// both scripts; mono is opt-in per style and never the default.
  static TextTheme _uiTextTheme(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;
    return GoogleFonts.ibmPlexSansArabicTextTheme(base);
  }

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: FontConstants.fontFamily,
      textTheme: _uiTextTheme(Brightness.light),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      primaryColor: ColorManager.primaryLt,
      scaffoldBackgroundColor: ColorManager.primaryLt,
      hintColor: ColorManager.cardLt,
      focusColor: ColorManager.textPrimaryLt,
      cardColor: ColorManager.cardLt,
      shadowColor: ColorManager.borderLt,
      appBarTheme: _appBarTheme(Brightness.light),
      highlightColor: ColorManager.transparent,
      canvasColor: ColorManager.transparent,
      splashColor: ColorManager.primaryLt,
      colorScheme: const ColorScheme.light(
        primary: ColorManager.cdPrimaryLt,
        onPrimary: ColorManager.cdOnPrimaryLt,
        secondary: ColorManager.cdSuccessLt,
        surface: ColorManager.cardLt,
        onSurface: ColorManager.textPrimaryLt,
        error: ColorManager.cdErrorLt,
        onError: ColorManager.cdOnErrorLt,
        outline: ColorManager.borderLt,
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: FontConstants.fontFamily,
      textTheme: _uiTextTheme(Brightness.dark),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      primaryColor: ColorManager.primaryDk,
      scaffoldBackgroundColor: ColorManager.primaryDk,
      hintColor: ColorManager.cardDk,
      focusColor: ColorManager.textPrimaryDk,
      cardColor: ColorManager.cardDk,
      shadowColor: ColorManager.borderDk,
      highlightColor: ColorManager.transparent,
      canvasColor: ColorManager.transparent,
      splashColor: ColorManager.primaryDk,
      appBarTheme: _appBarTheme(Brightness.dark),
      colorScheme: const ColorScheme.dark(
        primary: ColorManager.cdPrimaryDk,
        onPrimary: ColorManager.cdOnPrimaryDk,
        secondary: ColorManager.cdSuccessDk,
        surface: ColorManager.cdSurfaceDk,
        onSurface: ColorManager.textPrimaryDk,
        error: ColorManager.cdErrorDk,
        onError: ColorManager.cdOnErrorDk,
        outline: ColorManager.borderDk,
      ),
    );
  }

  static AppBarTheme _appBarTheme(Brightness brightness) {
    final bg = brightness == Brightness.dark ? ColorManager.primaryDk : ColorManager.primaryLt;
    final fg = brightness == Brightness.dark ? ColorManager.textPrimaryDk : ColorManager.textPrimaryLt;
    return AppBarTheme(
      elevation: 0,
      titleSpacing: 5.w,
      surfaceTintColor: bg,
      backgroundColor: bg,
      shadowColor: ColorManager.grey2,
      scrolledUnderElevation: 1.5.r,
      iconTheme: IconThemeData(color: fg),
      titleTextStyle: GetRegularStyle(fontSize: 16, color: fg),
    );
  }
}
