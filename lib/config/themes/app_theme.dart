import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/styles_manager.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: FontConstants.fontFamily,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      primaryColor: ColorManager.primaryLt,
      scaffoldBackgroundColor: ColorManager.primaryLt,
      hintColor: ColorManager.cardLt,
      focusColor: ColorManager.black,
      cardColor: ColorManager.cardLt,
      shadowColor: ColorManager.borderLt,
      appBarTheme: _appBarLightTheme(),
      highlightColor: ColorManager.transparent,
      canvasColor: ColorManager.transparent,
      splashColor: ColorManager.primaryLt,
      colorScheme: const ColorScheme.highContrastDark(
        primaryContainer: ColorManager.grey,
        surface: ColorManager.cardLt,
        primary: ColorManager.accentLt,
        secondary: ColorManager.accentGreenLt,
        error: ColorManager.accentRedLt,
        onSurface: ColorManager.textPrimaryLt,
      ),
    );
  }

  static AppBarTheme _appBarLightTheme() {
    return AppBarTheme(
      elevation: 0,
      titleSpacing: 5.w,
      surfaceTintColor: ColorManager.primaryLt,
      backgroundColor: ColorManager.primaryLt,
      shadowColor: ColorManager.grey2,
      scrolledUnderElevation: 1.5.r,
      iconTheme: const IconThemeData(color: ColorManager.black),
      titleTextStyle: const GetRegularStyle(fontSize: 16, color: ColorManager.black),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: FontConstants.fontFamily,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      primaryColor: ColorManager.primaryDk,
      scaffoldBackgroundColor: ColorManager.primaryDk,
      hintColor: ColorManager.cardDk,
      focusColor: ColorManager.white,
      cardColor: ColorManager.cardDk,
      shadowColor: ColorManager.borderDk,
      highlightColor: ColorManager.transparent,
      canvasColor: ColorManager.transparent,
      splashColor: ColorManager.primaryDk,
      appBarTheme: _appBarDarkTheme(),
      colorScheme: const ColorScheme.highContrastDark(
        primaryContainer: ColorManager.grey,
        surface: ColorManager.cardDk,
        primary: ColorManager.accentDk,
        secondary: ColorManager.accentGreenDk,
        error: ColorManager.accentRedDk,
        onSurface: ColorManager.textPrimaryDk,
      ),
    );
  }

  static AppBarTheme _appBarDarkTheme() {
    return AppBarTheme(
      elevation: 0,
      titleSpacing: 5.w,
      surfaceTintColor: ColorManager.primaryDk,
      backgroundColor: ColorManager.primaryDk,
      shadowColor: ColorManager.grey2,
      scrolledUnderElevation: 1.5.r,
      iconTheme: const IconThemeData(color: ColorManager.white),
      titleTextStyle: const GetRegularStyle(fontSize: 16, color: ColorManager.white),
    );
  }
}
