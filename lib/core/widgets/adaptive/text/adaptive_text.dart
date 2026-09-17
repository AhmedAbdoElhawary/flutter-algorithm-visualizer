import 'package:algorithm_visualizer/core/localization/app_localizations.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/styles_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

part 'bold_text.dart';
part 'light_text.dart';
part 'medium_text.dart';
part 'regular_text.dart';
part 'semi_bold_text.dart';

class _AdaptiveText extends StatelessWidget {
  const _AdaptiveText(
    this.text, {
    this.fontSize = 16,
    this.decoration = TextDecoration.none,
    this.fontStyle = FontStyle.normal,
    this.color,
    this.shadows,
    this.fontFamily,
    this.height,
    this.fontWeight = FontWeightManager.regular,
    this.maxLines = 2,
    this.letterSpacing = 0,
    this.translate = true,
    required this.textAlign,
    super.key,
  });
  final double? height;
  final String text;
  final String? fontFamily;
  final bool translate;
  final double fontSize;
  final double letterSpacing;
  final int maxLines;
  final ThemeEnum? color;
  final FontStyle fontStyle;
  final TextDecoration decoration;
  final FontWeight fontWeight;
  final TextAlign? textAlign;
  final List<Shadow>? shadows;
  @override
  Widget build(BuildContext context) {
    final color = this.color;
    final l10n = AppLocalizations.of(context);

    /// This is the single place the app translates anything. Every label in
    /// the tree reaches `Text` through here, so the look-up costs one
    /// inherited-widget read and one map hit per text widget — and a string
    /// with no entry in the table simply comes back as itself.
    ///
    /// [translate] is the opt-out for text that is *content* rather than
    /// chrome: the learner's own code, a problem statement, an identifier.
    final resolved = translate ? l10n.tr(text) : text;

    return Text(
      resolved,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      style: GetTextStyle(
        fontSize: fontSize.sp,
        height: height,
        color: color == null ? null : context.getColor(color),
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        decoration: decoration,
        decorationThickness: decoration == TextDecoration.none ? null : 1.r,
        shadows: shadows,
        letterSpacing: _resolveLetterSpacing(l10n.isArabic),
        fontFamily: fontFamily,
      ),
    );
  }

  /// Tracking is a Latin typography control, and it is dropped for Arabic
  /// in **both** directions.
  ///
  /// Latin is built from separate glyphs, so nudging them apart or together
  /// is a legitimate display effect — this app uses -1.9 on the splash
  /// wordmark, -0.5 on headlines, +1.2 on small caps labels. Arabic is
  /// cursive: its letters join into a single stroke. Negative tracking makes
  /// them collide, positive tracking prises apart a join that is supposed to
  /// be continuous. Neither looks like a style choice, both look like a bug.
  double _resolveLetterSpacing(bool isArabic) => isArabic ? 0 : letterSpacing;
}

class AdaptiveText extends StatelessWidget {
  const AdaptiveText(
    this.text, {
    this.style,
    this.maxLines = 2,
    this.textAlign,
    this.translate = true,
    super.key,
  });

  final String text;
  final int maxLines;
  final TextAlign? textAlign;
  final TextStyle? style;

  /// Pass `false` for content the app did not author — code, problem
  /// statements, anything the user typed. See [_AdaptiveText.translate].
  final bool translate;

  @override
  Widget build(BuildContext context) {
    final style = this.style;
    final l10n = AppLocalizations.of(context);

    final TextStyle base = style == null
        ? GetRegularStyle(fontSize: 16.sp)
        : style.copyWith(
            fontSize: (style.fontSize ?? 16).sp,
          );

    /// Same rule as [_AdaptiveText]: a caller-supplied style can carry
    /// tracking too, so it has to be caught here as well.
    final TextStyle newStyle =
        l10n.isArabic && (base.letterSpacing ?? 0) != 0 ? base.copyWith(letterSpacing: 0) : base;

    return Text(
      translate ? l10n.tr(text) : text,
      maxLines: maxLines,
      textAlign: textAlign,
      style: newStyle,
    );
  }
}
