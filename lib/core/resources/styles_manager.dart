import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:flutter/material.dart';
import 'package:algorithm_visualizer/core/resources/color_manager.dart';

class GetTextStyle extends TextStyle {
  const GetTextStyle({
    required double fontSize,
    super.height,
    required super.fontWeight,
    super.color,
    required FontStyle super.fontStyle,
    required TextDecoration super.decoration,
    super.decorationThickness,
    super.letterSpacing = 0,
    super.shadows,
    super.wordSpacing = 1,
  }) : super(fontSize: fontSize, fontFamily: FontConstants.fontFamily);
}

class GetLightStyle extends GetTextStyle {
  const GetLightStyle({
    super.fontSize = 16,
    super.height,
    super.color = ColorManager.black,
    super.fontStyle = FontStyle.normal,
    super.decoration = TextDecoration.none,
    super.decorationThickness,
    super.letterSpacing,
    super.shadows,
  }) : super(fontWeight: FontWeightManager.light);
}

class GetRegularStyle extends GetTextStyle {
  const GetRegularStyle({
    super.fontSize = 16,
    super.height,
    super.color = ColorManager.black,
    super.fontStyle = FontStyle.normal,
    super.decoration = TextDecoration.none,
    super.decorationThickness,
    super.letterSpacing,
    super.shadows,
  }) : super(fontWeight: FontWeightManager.regular);
}

class GetMediumStyle extends GetTextStyle {
  const GetMediumStyle({
    super.fontSize = 16,
    super.height,
    super.color = ColorManager.black,
    super.fontStyle = FontStyle.normal,
    super.decoration = TextDecoration.none,
    super.decorationThickness,
    super.letterSpacing,
    super.shadows,
  }) : super(fontWeight: FontWeightManager.medium);
}

class GetSemiBoldStyle extends GetTextStyle {
  const GetSemiBoldStyle({
    super.fontSize = 16,
    super.height,
    super.color = ColorManager.black,
    super.fontStyle = FontStyle.normal,
    super.decoration = TextDecoration.none,
    super.decorationThickness,
    super.letterSpacing,
    super.shadows,
  }) : super(fontWeight: FontWeightManager.semiBold);
}

class GetBoldStyle extends GetTextStyle {
  const GetBoldStyle({
    super.fontSize = 16,
    super.height,
    super.color = ColorManager.black,
    super.fontStyle = FontStyle.normal,
    super.decoration = TextDecoration.none,
    super.decorationThickness,
    super.letterSpacing,
    super.shadows,
  }) : super(fontWeight: FontWeightManager.bold);
}
