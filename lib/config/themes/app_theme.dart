import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/styles_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  /// IBM Plex Sans Arabic, bundled as an asset font (see pubspec.yaml). One
  /// family for both scripts; mono is opt-in per style and never the default.
  static TextTheme _uiTextTheme(Brightness brightness) {
    final base = brightness == Brightness.dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    return base.apply(fontFamily: FontConstants.fontFamily);
  }

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: FontConstants.fontFamily,
      textTheme: _uiTextTheme(Brightness.light),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      primaryColor: ColorManager.groundLt,
      scaffoldBackgroundColor: ColorManager.groundLt,
      hintColor: ColorManager.surfaceLt,
      focusColor: ColorManager.inkTitleLt,
      cardColor: ColorManager.surfaceLt,
      shadowColor: ColorManager.hairlineLt,
      appBarTheme: _appBarTheme(Brightness.light),
      highlightColor: ColorManager.transparent,
      canvasColor: ColorManager.transparent,
      splashColor: ColorManager.groundLt,
      colorScheme: const ColorScheme.light(
        primary: ColorManager.inkPrimaryLt,
        onPrimary: ColorManager.groundLt,
        secondary: ColorManager.dataEasyLt,
        surface: ColorManager.surfaceLt,
        onSurface: ColorManager.inkTitleLt,
        error: ColorManager.dataHardLt,
        onError: ColorManager.groundLt,
        outline: ColorManager.hairlineLt,
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
      primaryColor: ColorManager.groundDk,
      scaffoldBackgroundColor: ColorManager.groundDk,
      hintColor: ColorManager.surfaceDk,
      focusColor: ColorManager.inkTitleDk,
      cardColor: ColorManager.surfaceDk,
      shadowColor: ColorManager.hairlineDk,
      highlightColor: ColorManager.transparent,
      canvasColor: ColorManager.transparent,
      splashColor: ColorManager.groundDk,
      appBarTheme: _appBarTheme(Brightness.dark),
      colorScheme: const ColorScheme.dark(
        primary: ColorManager.inkPrimaryDk,
        onPrimary: ColorManager.groundDk,
        secondary: ColorManager.dataEasyDk,
        surface: ColorManager.surfaceDk,
        onSurface: ColorManager.inkTitleDk,
        error: ColorManager.dataHardDk,
        onError: ColorManager.groundDk,
        outline: ColorManager.hairlineDk,
      ),
    );
  }

  static AppBarTheme _appBarTheme(Brightness brightness) {
    final bg = brightness == Brightness.dark ? ColorManager.groundDk : ColorManager.groundLt;
    final fg = brightness == Brightness.dark ? ColorManager.inkTitleDk : ColorManager.inkTitleLt;
    return AppBarTheme(
      elevation: 0,
      titleSpacing: 5.w,
      surfaceTintColor: bg,
      backgroundColor: bg,
      shadowColor: ColorManager.hairlineDk,
      scrolledUnderElevation: 1.5.r,
      iconTheme: IconThemeData(color: fg),
      titleTextStyle: GetRegularStyle(fontSize: 16, color: fg),
    );
  }
}
