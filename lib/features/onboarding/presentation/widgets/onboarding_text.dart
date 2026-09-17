import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/styles_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MonoText extends StatelessWidget {
  const MonoText(
    this.text, {
    this.color = ThemeEnum.inkBody,
    this.fontSize = 12,
    this.letterSpacing = 0,
    this.textAlign,
    this.translate = true,
    super.key,
  });

  final String text;
  final ThemeEnum color;
  final double fontSize;
  final double letterSpacing;
  final TextAlign? textAlign;

  /// Off for the file name and language chips — those are identifiers.
  final bool translate;

  @override
  Widget build(BuildContext context) {
    return RegularText(
      text,
      fontSize: fontSize,
      color: color,
      maxLines: 1,
      textAlign: textAlign,
      letterSpacing: letterSpacing,
      fontFamily: FontConstants.fontFamily,
      translate: translate,
    );
  }
}

class MonoBoldText extends StatelessWidget {
  const MonoBoldText(this.text, {required this.color, this.fontSize = 13, super.key});

  final String text;
  final ThemeEnum color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return BoldText(
      text,
      fontSize: fontSize,
      color: color,
      maxLines: 1,
      fontFamily: FontConstants.fontFamily,
    );
  }
}

/// Headline + body pair under every visual card.
///
/// [AdaptiveText] with an explicit [GetSemiBoldStyle] is used for the headline
/// because `SemiBoldText` does not expose `height`, and the spec pins the
/// headline leading at 1.1.
class OnboardingCopy extends StatelessWidget {
  const OnboardingCopy({required this.headline, required this.body, super.key});

  final String headline;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AdaptiveText(
          headline,
          maxLines: 3,
          style: GetSemiBoldStyle(
            fontSize: 28,
            height: 1.1,
            letterSpacing: -0.6,
            color: context.getColor(ThemeEnum.inkTitle),
          ),
        ),
        const RSizedBox(height: 12),
        RegularText(
          body,
          fontSize: 14,
          height: 1.5,
          color: ThemeEnum.inkBody,
          maxLines: 3,
        ),
      ],
    );
  }
}
