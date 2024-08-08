import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/styles_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

part 'light_text.dart';
part 'regular_text.dart';
part 'semi_bold_text.dart';
part 'bold_text.dart';
part 'medium_text.dart';

class _AdaptiveText extends StatelessWidget {
  const _AdaptiveText(
    this.text, {
    this.fontSize = 16,
    this.decoration = TextDecoration.none,
    this.fontStyle = FontStyle.normal,
    this.color,
    this.shadows,
    this.fontWeight = FontWeightManager.regular,
    this.maxLines = 2,
    this.letterSpacing = 0,
    this.translate = true,
    required this.textAlign,
    super.key,
  });

  final String text;
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

    /// todo: tr

    final text = (translate
            ? this.text
            // .tr
            : this.text)
        .trim();

    // final actualWeight = text.getExtraWeightForArabic(fontWeight);
    final actualWeight = fontWeight;

    return Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      style: GetTextStyle(
        fontSize: fontSize.sp,
        color: color == null ? null : context.getColor(color),
        fontWeight: actualWeight,
        fontStyle: fontStyle,
        decoration: decoration,
        decorationThickness: decoration == TextDecoration.none ? null : 3.h,
        shadows: shadows,
        letterSpacing: letterSpacing,
      ),
    );
  }
}

class AdaptiveText extends StatelessWidget {
  const AdaptiveText(
    this.text, {
    this.style,
    this.maxLines = 2,
    this.textAlign,
    super.key,
  });

  final String text;
  final int maxLines;
  final TextAlign? textAlign;
  final TextStyle? style;
  @override
  Widget build(BuildContext context) {
    final style = this.style;

    final TextStyle newStyle = style == null
        ? const GetRegularStyle()
        : style.copyWith(
            fontSize: (style.fontSize ?? 16).sp,
          );

    /// todo: tr

    return Text(
      text
      // .tr
      ,
      maxLines: maxLines,
      textAlign: textAlign,
      style: newStyle,
    );
  }
}
