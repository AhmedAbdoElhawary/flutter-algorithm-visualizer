import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/styles_manager.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: FontConstants.fontFamily,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      primaryColor: ColorManager.white,
      primaryColorLight: ColorManager.whiteD2,
      hintColor: ColorManager.greyD4,
      shadowColor: ColorManager.blackOp10,
      focusColor: ColorManager.black,
      disabledColor: ColorManager.blackOp50,
      switchTheme: const SwitchThemeData(),
      dialogBackgroundColor: ColorManager.whiteD1,
      hoverColor: ColorManager.blackOp50,
      indicatorColor: ColorManager.blackOp40,
      highlightColor: ColorManager.whiteD3,
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: ColorManager.white,
        surfaceTintColor: ColorManager.white,
        shadowColor: ColorManager.white,
      ),
      dialogTheme: const DialogTheme(surfaceTintColor: ColorManager.whiteD5),
      dividerColor: ColorManager.blackOp10,
      scaffoldBackgroundColor: ColorManager.white,
      iconTheme: const IconThemeData(color: ColorManager.black),
      outlinedButtonTheme: _outlinedButtonTheme(),
      elevatedButtonTheme: _elevatedButtonThemeData(),
      textButtonTheme: const TextButtonThemeData(
          style: ButtonStyle(
            overlayColor: WidgetStatePropertyAll(
              ColorManager.whiteD3,
            ),
          )),
      chipTheme: const ChipThemeData(backgroundColor: ColorManager.blackOp10),
      canvasColor: ColorManager.transparent,
      splashColor: ColorManager.white,
      appBarTheme: _appBarTheme(),
      tabBarTheme: _tabBarTheme(),
      textTheme: _textTheme(),
      dividerTheme: const DividerThemeData(color: ColorManager.whiteD5),
      bottomAppBarTheme: const BottomAppBarTheme(color: ColorManager.blackOp30),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: ColorManager.teal,
        selectionColor: ColorManager.blackOp10,
        selectionHandleColor: ColorManager.black,
      ),
      listTileTheme: const ListTileThemeData(),
      colorScheme: const ColorScheme.highContrastLight(
        // circle avatar color
        primaryContainer: ColorManager.whiteD4,
        surface: ColorManager.whiteD3,
      )
          .copyWith(surface: ColorManager.whiteD5)
          .copyWith(error: ColorManager.black),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonThemeData() {
    return ElevatedButtonThemeData(
      style: ButtonStyle(
        fixedSize: WidgetStateProperty.all<Size>(Size(double.maxFinite, 45.r)),
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                (_) => ColorManager.whiteD2),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (_) => ColorManager.whiteOp20),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        fixedSize: Size(double.maxFinite, 45.r),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.r)),
        side: BorderSide(width: 1.r, color: ColorManager.whiteD5),
      ),
    );
  }

  static TabBarTheme _tabBarTheme() {
    return TabBarTheme(
      indicatorSize: TabBarIndicatorSize.label,
      labelPadding: EdgeInsets.zero,
      indicator: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ColorManager.black, width: 1.5.r),
        ),
      ),
      labelColor: ColorManager.black,
      unselectedLabelColor: ColorManager.grey,
    );
  }

  static TextTheme _textTheme() {
    return TextTheme(
      bodyLarge: _getStyle(const GetRegularStyle(color: ColorManager.greyD4)),
      bodyMedium: _getStyle(
          const GetRegularStyle(color: ColorManager.greyD5, fontSize: 12)),
      bodySmall: _getStyle(const GetRegularStyle(color: ColorManager.greyD2)),
      titleSmall: _getStyle(const GetRegularStyle(color: ColorManager.greyD2)),
      labelSmall: _getStyle(const GetMediumStyle(color: ColorManager.greyD2)),
      displaySmall: _getStyle(const GetMediumStyle(color: ColorManager.greyD2)),
      displayLarge: _getStyle(const GetMediumStyle(color: ColorManager.grey)),
      displayMedium: _getStyle(const GetMediumStyle(color: ColorManager.grey)),
      headlineLarge:
      _getStyle(const GetRegularStyle(color: ColorManager.whiteD3)),
      headlineMedium:
      _getStyle(const GetRegularStyle(color: ColorManager.greyD2)),
      headlineSmall:
      _getStyle(const GetRegularStyle(color: ColorManager.greyD2)),
      labelLarge: _getStyle(const GetRegularStyle(color: ColorManager.greyD2)),
      labelMedium: _getStyle(const GetRegularStyle(color: ColorManager.greyD2)),
      titleLarge: _getStyle(const GetRegularStyle(color: ColorManager.greyD2)),
      titleMedium: _getStyle(const GetRegularStyle(color: ColorManager.greyD2)),
    );
  }

  static TextStyle _getStyle(TextStyle style) {
    return style;
  }

  static AppBarTheme _appBarTheme() {
    return AppBarTheme(
      elevation: 0,
      titleSpacing: 5.w,
      surfaceTintColor: ColorManager.white,
      color: ColorManager.white,
      shadowColor: ColorManager.blackOp20,
      scrolledUnderElevation: 1.5.r,
      iconTheme: const IconThemeData(color: ColorManager.black),
      titleTextStyle: const GetRegularStyle(
          fontSize: 16, color: ColorManager.black),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      fontFamily: FontConstants.fontFamily,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      primaryColor: ColorManager.blackBlue,
      primaryColorLight: ColorManager.blackL2,
      hintColor: ColorManager.greyD4,
      shadowColor: ColorManager.whiteOp10,
      focusColor: ColorManager.white,
      disabledColor: ColorManager.whiteOp50,
      dialogBackgroundColor: ColorManager.blackL1,
      hoverColor: ColorManager.whiteOp50,
      indicatorColor: ColorManager.whiteOp40,
      highlightColor: ColorManager.blackL3Blue,
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: ColorManager.blackL5,
        surfaceTintColor: ColorManager.blackL5,
        shadowColor: ColorManager.blackL5,
      ),
      dialogTheme: const DialogTheme(surfaceTintColor: ColorManager.blackL5),
      dividerColor: ColorManager.whiteOp10,
      scaffoldBackgroundColor: ColorManager.blackBlue,
      iconTheme: const IconThemeData(color: ColorManager.white),
      outlinedButtonTheme: _outlinedButtonDarkTheme(),
      elevatedButtonTheme: _elevatedButtonDarkThemeData(),
      textButtonTheme: const TextButtonThemeData(
        style: ButtonStyle(
          overlayColor: WidgetStatePropertyAll(ColorManager.blackL3Blue),
        ),
      ),
      chipTheme: const ChipThemeData(backgroundColor: ColorManager.whiteOp10),
      canvasColor: ColorManager.transparent,
      splashColor: ColorManager.blackBlue,
      appBarTheme: _appBarDarkTheme(),
      tabBarTheme: _tabBarDarkTheme(),
      textTheme: _textDarkTheme(),
      dividerTheme: const DividerThemeData(color: ColorManager.blackL5),
      bottomAppBarTheme: const BottomAppBarTheme(color: ColorManager.whiteOp30),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: ColorManager.teal,
        selectionColor: ColorManager.greyD6,
        selectionHandleColor: ColorManager.white,
      ),
      colorScheme: const ColorScheme.highContrastDark(
        primaryContainer: ColorManager.blackL4,
        surface: ColorManager.blackL6,
      )
          .copyWith(surface: ColorManager.blackL6)
          .copyWith(error: ColorManager.white),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonDarkThemeData() {
    return ElevatedButtonThemeData(
      style: ButtonStyle(
        fixedSize: WidgetStateProperty.all<Size>(Size(double.maxFinite, 45.r)),
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                (_) => ColorManager.blackL2),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (_) => ColorManager.blackOp20),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonDarkTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        fixedSize: Size(double.maxFinite, 45.r),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.r)),
        side: BorderSide(width: 1.r, color: ColorManager.whiteD5),
      ),
    );
  }

  static TabBarTheme _tabBarDarkTheme() {
    return TabBarTheme(
      indicatorSize: TabBarIndicatorSize.label,
      labelPadding: EdgeInsets.zero,
      indicator: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ColorManager.white, width: 1.5.r),
        ),
      ),
      labelColor: ColorManager.white,
      unselectedLabelColor: ColorManager.grey,
    );
  }

  static TextTheme _textDarkTheme() {
    return TextTheme(
      bodyLarge: _getStyle(const GetRegularStyle(color: ColorManager.greyD1)),
      bodyMedium: _getStyle(
          const GetRegularStyle(color: ColorManager.grey, fontSize: 12)),
      bodySmall: _getStyle(const GetRegularStyle(color: ColorManager.greyD2)),
      titleSmall: _getStyle(const GetRegularStyle(color: ColorManager.greyD2)),
      labelSmall: _getStyle(const GetMediumStyle(color: ColorManager.greyD2)),
      displaySmall: _getStyle(const GetMediumStyle(color: ColorManager.greyD2)),
      displayLarge: _getStyle(const GetMediumStyle(color: ColorManager.grey)),
      displayMedium: _getStyle(const GetMediumStyle(color: ColorManager.grey)),
      headlineLarge:
      _getStyle(const GetRegularStyle(color: ColorManager.blackL3Blue)),
      headlineMedium:
      _getStyle(const GetRegularStyle(color: ColorManager.greyD2)),
      headlineSmall:
      _getStyle(const GetRegularStyle(color: ColorManager.greyD2)),
      labelLarge: _getStyle(const GetRegularStyle(color: ColorManager.greyD2)),
      labelMedium: _getStyle(const GetRegularStyle(color: ColorManager.greyD2)),
      titleLarge: _getStyle(const GetRegularStyle(color: ColorManager.greyD2)),
      titleMedium: _getStyle(const GetRegularStyle(color: ColorManager.greyD2)),
    );
  }

  static AppBarTheme _appBarDarkTheme() {
    return AppBarTheme(
      elevation: 0,
      titleSpacing: 5.w,
      surfaceTintColor: ColorManager.blackBlue,
      color: ColorManager.blackBlue,
      shadowColor: ColorManager.greyD8,
      scrolledUnderElevation: 1.5.r,
      iconTheme: const IconThemeData(color: ColorManager.white),
      titleTextStyle: const GetRegularStyle(
          fontSize:16, color: ColorManager.white),
    );
  }
}
