import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:flutter/material.dart';

enum ThemeEnum {
  primaryColor,
  focusColor,
  hintColor,

  whiteD1Color,
  whiteD2Color,
  whiteD3Color,
  whiteD4Color,
  whiteD5Color,
  whiteD7Color,
  whiteColor,
  transparentWhiteColor,
  transparentColor,
  blackColor,
  whiteOp60Color,
  solidWhiteOp60Color,
  whiteOp50Color,
  whiteOp20Color,
  greyColor,
  grey5Color,
  darkGreyColor,
  trendsRankingColor,
  hoverColor,
  blackOp80,
  blackOp50,
  blackOp20,
  blackOp10,
  bottomSheetColor,

  blueColor,
  darkBlueColor,
  lightBlueColor,
  greenColor,
  redColor,
  orangeColor,
}
//
// abstract class BaseGetColor extends Color {
//   const BaseGetColor(this.color, super.value);
//   final ThemeEnum color;
//
//   getColor(BuildContext context) => context._getColor(color);
// }

// class GetColor extends Color {
//   const GetColor(this.color)
//       : super(AppSettingsViewModel.getInstance().isThemeLight ? 0 : 1);
//   final ThemeEnum color;
//
//   getColor(BuildContext context) => context._getColor(color);
//
//   static Map<ThemeEnum, int> get _colors {
//     final isLight = AppSettingsViewModel.getInstance().isThemeLight;
//     return {
//       ThemeEnum.whiteD5Color:
//           isLight ? ColorManager.whiteD5 : ColorManager.blackL5,
//       ThemeEnum.whiteD7Color:
//           isLight ? ColorManager.whiteD7 : ColorManager.blackL6,
//       ThemeEnum.transparentColor: ColorManager.transparent,
//       ThemeEnum.transparentWhiteColor: ColorManager.whiteOp20,
//       ThemeEnum.blackOp20: ColorManager.blackOp20,
//       ThemeEnum.trendsRankingColor: ColorManager.rankingGrey,
//       ThemeEnum.whiteColor: ColorManager.white,
//       ThemeEnum.blackColor: ColorManager.black,
//       ThemeEnum.whiteOp60Color:
//           isLight ? ColorManager.whiteOp60 : ColorManager.blackOp60,
//       ThemeEnum.whiteOp50Color:
//           isLight ? ColorManager.whiteOp50 : ColorManager.blackOp50,
//       ThemeEnum.whiteOp20Color:
//           isLight ? ColorManager.whiteOp20 : ColorManager.blackOp20,
//       ThemeEnum.blackOp80: ColorManager.blackOp80,
//       ThemeEnum.blackOp50:
//           isLight ? ColorManager.blackOp50 : ColorManager.whiteOp50,
//       ThemeEnum.greyColor: ColorManager.grey,
//       ThemeEnum.grey5Color:
//           isLight ? ColorManager.greyD9 : ColorManager.whiteD4,
//       ThemeEnum.blueColor: ColorManager.blue,
//       ThemeEnum.darkBlueColor: ColorManager.darkBlue,
//       ThemeEnum.lightBlueColor: ColorManager.lightBlue,
//       ThemeEnum.greenColor: ColorManager.green,
//       ThemeEnum.redColor: ColorManager.red,
//       ThemeEnum.orangeColor: ColorManager.orange,
//     };
//   }
// }

extension ThemeExtension on BuildContext {
  Map<ThemeEnum, Color> get _colors {
    // final isLight = AppSettingsViewModel.getInstance().isThemeLight;

    return {
      ThemeEnum.primaryColor: Theme.of(this).primaryColor,
      ThemeEnum.focusColor: Theme.of(this).focusColor,
      ThemeEnum.hintColor: Theme.of(this).hintColor,

      /// what ever dark or light. Maybe if we have multiple themes, it will save a lot of time.
      ThemeEnum.whiteD1Color: Theme.of(this).dialogBackgroundColor,
      ThemeEnum.whiteD2Color: Theme.of(this).primaryColorLight,
      ThemeEnum.bottomSheetColor:
          Theme.of(this).bottomSheetTheme.backgroundColor ??
              Theme.of(this).primaryColorLight,
      ThemeEnum.whiteD3Color:
          Theme.of(this).textTheme.headlineLarge?.color ?? ColorManager.grey,
      ThemeEnum.whiteD4Color: Theme.of(this).colorScheme.primaryContainer,
      ThemeEnum.whiteD5Color: ColorManager.whiteD5,
      ThemeEnum.whiteD7Color: ColorManager.whiteD7,
      ThemeEnum.transparentColor: ColorManager.transparent,
      ThemeEnum.transparentWhiteColor: ColorManager.whiteOp20,
      ThemeEnum.blackOp20: ColorManager.blackOp20,
      ThemeEnum.trendsRankingColor: ColorManager.rankingGrey,

      ThemeEnum.blackOp10: Theme.of(this).dividerColor,

      ThemeEnum.whiteColor: ColorManager.white,
      ThemeEnum.blackColor: ColorManager.black,
      ThemeEnum.whiteOp60Color: ColorManager.whiteOp60,
      ThemeEnum.solidWhiteOp60Color: ColorManager.whiteOp60,
      ThemeEnum.whiteOp50Color: ColorManager.whiteOp50,
      ThemeEnum.whiteOp20Color: ColorManager.whiteOp20,
      ThemeEnum.blackOp80: ColorManager.blackOp80,
      ThemeEnum.blackOp50: ColorManager.blackOp50,
      ThemeEnum.hoverColor: Theme.of(this).hoverColor,

      ThemeEnum.greyColor: ColorManager.grey,
      ThemeEnum.grey5Color: ColorManager.greyD9,
      ThemeEnum.darkGreyColor:
          Theme.of(this).textTheme.bodyLarge?.color ?? ColorManager.greyD3,
      ThemeEnum.blueColor: ColorManager.blue,
      ThemeEnum.darkBlueColor: ColorManager.darkBlue,
      ThemeEnum.lightBlueColor: ColorManager.lightBlue,
      ThemeEnum.greenColor: ColorManager.green,
      ThemeEnum.redColor: ColorManager.red,
      ThemeEnum.orangeColor: ColorManager.orange,
    };
  }

  Color getColor(ThemeEnum color) =>
      _colors[color] ?? Theme.of(this).primaryColor;
}
