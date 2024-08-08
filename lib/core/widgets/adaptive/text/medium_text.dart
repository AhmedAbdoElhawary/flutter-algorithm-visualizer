part of 'adaptive_text.dart';

class MediumText extends _AdaptiveText {
  const MediumText(
    super.text, {
    super.fontSize = 16,
    super.decoration = TextDecoration.none,
    super.fontStyle = FontStyle.normal,
    super.color = ThemeEnum.focusColor,
    super.textAlign,
    super.maxLines,
    super.translate,
    super.shadows,
    super.letterSpacing,
    super.key,
  }) : super(fontWeight: FontWeightManager.medium);
}
