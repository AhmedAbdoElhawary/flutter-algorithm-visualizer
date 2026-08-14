import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:flutter/material.dart';

enum ThemeEnum {
  primary,
  focus,
  card,
  mainCard,
  outputHeader,
  accent,
  borderAccent,
  accentBg,
  accentGreen,
  accentGreenBg,
  accentGreenRc,
  accentYellow,
  accentYellowRc,
  accentRed,
  accentRedRc,
  accentBlue,
  textSecond,
  textPrimary,
  hover,
  hoverSecond,
  border,

  /// --------------
  howItWorksColor,
  columnColor,
  backgroundForSortingColor,
  white2DarkColor,
  textDarkColor,
  text2DarkColor,
  borderPurpleColor,
  lightPurpleColor,
  codeEditorNumberColor,

  whiteD4Color,
  whiteD5Color,
  whiteColor,
  transparentColor,

  //
}

extension ThemeExtension on BuildContext {
  bool get isThemeDark => Theme.of(this).brightness == Brightness.dark;

  List<BoxShadow> get cardShadow => isThemeDark
      ? []
      : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 2)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), spreadRadius: 1),
        ];

  Map<ThemeEnum, Color> get _colors {
    return {
      ThemeEnum.primary: Theme.of(this).primaryColor,
      ThemeEnum.focus: Theme.of(this).focusColor,
      ThemeEnum.card: Theme.of(this).hintColor,
      ThemeEnum.mainCard: ColorManager.mainCardDk,
      ThemeEnum.outputHeader: isThemeDark ? ColorManager.outputHeaderDk : ColorManager.outputHeaderLt,
      ThemeEnum.accent: isThemeDark ? ColorManager.accentDk : ColorManager.accentLt,
      ThemeEnum.borderAccent: isThemeDark
          ? ColorManager.accentDk.withValues(alpha: 0.22)
          : ColorManager.accentLt.withValues(alpha: 0.25),
      ThemeEnum.accentBg: isThemeDark
          ? ColorManager.accentDk.withValues(alpha: 0.12)
          : ColorManager.accentLt.withValues(alpha: 0.08),
      ThemeEnum.accentGreenRc:  ColorManager.accentGreenBgDk,
      ThemeEnum.accentGreen: isThemeDark ? ColorManager.accentGreenDk : ColorManager.accentGreenLt,
      ThemeEnum.accentGreenBg: isThemeDark
          ? ColorManager.accentGreenDk.withValues(alpha: 0.12)
          : ColorManager.accentGreenLt.withValues(alpha: 0.08),
      ThemeEnum.accentYellow: isThemeDark ? ColorManager.accentYellowDk : ColorManager.accentYellowLt,
      ThemeEnum.accentYellowRc:  ColorManager.accentYellowBgDk ,
      ThemeEnum.accentRed: isThemeDark ? ColorManager.accentRedDk : ColorManager.accentRedLt,
      ThemeEnum.accentRedRc:  ColorManager.accentRedBgDk ,
      ThemeEnum.accentBlue: isThemeDark ? ColorManager.accentBlueDk : ColorManager.accentBlueLt,
      ThemeEnum.textSecond: isThemeDark ? ColorManager.textSecondDk : ColorManager.textSecondLt,
      ThemeEnum.textPrimary: isThemeDark ? ColorManager.textPrimaryDk : ColorManager.textPrimaryLt,
      ThemeEnum.hover: isThemeDark ? ColorManager.hoverDk : ColorManager.hoverLt,
      ThemeEnum.hoverSecond: isThemeDark ? ColorManager.hoverSecondDk : ColorManager.hoverSecondLt,
      ThemeEnum.border: isThemeDark ? ColorManager.borderDk : ColorManager.borderLt,

      ///-------------------->
      ThemeEnum.howItWorksColor: ColorManager.howItWorksColor,
      ThemeEnum.white2DarkColor: ColorManager.white2DarkColor,
      ThemeEnum.columnColor: ColorManager.columnSortColor,
      ThemeEnum.backgroundForSortingColor: ColorManager.backgroundForSortingColor,
      ThemeEnum.textDarkColor: ColorManager.textDarkColor,
      ThemeEnum.text2DarkColor: ColorManager.text2DarkColor,
      ThemeEnum.lightPurpleColor: ColorManager.lightPurpleColor,
      ThemeEnum.borderPurpleColor: ColorManager.borderPurpleColor,

      /// what ever dark or light. Maybe if we have multiple themes, it will save a lot of time.
      ThemeEnum.whiteD4Color: ColorManager.grey,

      ThemeEnum.whiteD5Color: ColorManager.whiteD5,
      ThemeEnum.transparentColor: ColorManager.transparent,
      ThemeEnum.whiteColor: ColorManager.white,
      ThemeEnum.codeEditorNumberColor: ColorManager.codeEditorNumberColor,
    };
  }

  Color getColor(ThemeEnum color) => _colors[color] ?? Theme.of(this).primaryColor;
}
