part of 'adaptive_text.dart';

class SemiBoldText extends _AdaptiveText {
  const SemiBoldText(
    super.text, {
    super.fontSize = 16,
    super.decoration = TextDecoration.none,
    super.fontStyle = FontStyle.normal,
    super.color = ThemeEnum.focusColor,
    super.maxLines = 2,
    super.shadows,
    super.textAlign,
    super.letterSpacing,
    super.key,
  }) : super(fontWeight: FontWeightManager.semiBold);
}
