part of 'adaptive_text.dart';

class BoldText extends _AdaptiveText {
  const BoldText(
    super.text, {
    super.fontSize = 16,
    super.decoration = TextDecoration.none,
    super.fontStyle = FontStyle.normal,
    super.color = ThemeEnum.focusColor,
    super.shadows,
    super.fontWeight= FontWeightManager.bold,
    super.textAlign,
    super.maxLines = 2,
    super.key,
  }) ;
}
