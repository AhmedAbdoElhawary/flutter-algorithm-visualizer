import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/styles_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/onboarding/presentation/widgets/onboarding_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// JetBrains Mono line — legends, captions and the Skip label all use it.
class MonoText extends StatelessWidget {
  const MonoText(
    this.text, {
    this.color = OnboardingTokens.textBody,
    this.fontSize = OnboardingTokens.monoSize,
    this.letterSpacing = 0,
    this.textAlign,
    super.key,
  });

  final String text;
  final ThemeEnum color;
  final double fontSize;
  final double letterSpacing;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return RegularText(
      text,
      fontSize: fontSize,
      color: color,
      maxLines: 1,
      textAlign: textAlign,
      letterSpacing: letterSpacing,
      fontFamily: FontConstants.fontJetBrainsMono,
    );
  }
}

/// Bold mono — only the `12 / 12 passed` verdict uses this.
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
      fontFamily: FontConstants.fontJetBrainsMono,
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
            fontSize: OnboardingTokens.headlineSize,
            height: OnboardingTokens.headlineHeight,
            letterSpacing: OnboardingTokens.headlineTracking,
            color: context.getColor(OnboardingTokens.textHi),
          ),
        ),
        SizedBox(height: OnboardingTokens.headlineToBody.h),
        RegularText(
          body,
          fontSize: OnboardingTokens.bodySize,
          height: OnboardingTokens.bodyHeight,
          color: OnboardingTokens.textBody,
          maxLines: 3,
        ),
      ],
    );
  }
}
