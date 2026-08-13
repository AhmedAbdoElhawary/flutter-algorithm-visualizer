part of 'adaptive_text.dart';

class LightText extends _AdaptiveText {
  const LightText(
    super.text, {
    super.fontSize = 16,
    super.decoration = TextDecoration.none,
    super.fontStyle = FontStyle.normal,
    super.color = ThemeEnum.focus,
    super.maxLines = 2,
    super.textAlign,
    super.shadows,
    super.key,
  }) : super(fontWeight: FontWeightManager.light);
}
