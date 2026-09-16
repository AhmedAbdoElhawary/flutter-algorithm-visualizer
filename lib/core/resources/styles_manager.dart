import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:flutter/material.dart';

/// Every style here leaves `color` **null** on purpose.
///
/// A null colour inherits from the nearest `DefaultTextStyle`, which is the
/// active `ThemeData` — so the same style reads correctly in both themes.
/// These used to default to `ColorManager.groundDk`, a near-black that is
/// invisible on a dark page; it only went unnoticed because almost every call
/// site passes a colour explicitly.
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
    super.fontFamily,
    super.wordSpacing = 1,
  }) : super(fontSize: fontSize);
}

class GetLightStyle extends GetTextStyle {
  const GetLightStyle({
    super.fontSize = 16,
    super.height,
    super.color,
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
    super.color,
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
    super.color,
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
    super.color,
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
    super.color,
    super.fontStyle = FontStyle.normal,
    super.decoration = TextDecoration.none,
    super.decorationThickness,
    super.letterSpacing,
    super.shadows,
  }) : super(fontWeight: FontWeightManager.bold);
}
