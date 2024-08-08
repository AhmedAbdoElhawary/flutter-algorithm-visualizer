part of '../../adaptive/text/adaptive_text.dart';

class RegularText extends _AdaptiveText {
  const RegularText(
    super.text, {
    super.fontSize = 16,
    super.decoration = TextDecoration.none,
    super.fontStyle = FontStyle.normal,
    super.color,
    super.shadows,
    super.maxLines = 2,
    super.textAlign,
    super.key,
  }) : super(fontWeight: FontWeightManager.regular);
}
