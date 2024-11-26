import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomRoundedElevatedButton extends StatelessWidget {
  final ThemeEnum? backgroundColor;
  final ThemeEnum? shadowColor;
  final Widget child;
  final VoidCallback onPressed;
  final bool fitToContent;
  final double roundedRadius;
  final double fixedSize;
  const CustomRoundedElevatedButton({
    super.key,
    this.backgroundColor = ThemeEnum.focusColor,
    this.shadowColor = ThemeEnum.transparentColor,
    this.fitToContent = true,
    this.roundedRadius = 50,
    this.fixedSize = 35,
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = this.backgroundColor;
    final shadowColor = this.shadowColor;
    final background =
        backgroundColor == null ? null : context.getColor(backgroundColor);
    final shadow = shadowColor == null ? null : context.getColor(shadowColor);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        shadowColor: shadow ?? ColorManager.transparent,
        fixedSize: fitToContent ? Size.fromHeight(fixedSize.r) : null,
        padding: EdgeInsets.symmetric(horizontal: 15.r),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(roundedRadius).r),
        surfaceTintColor: background,
        foregroundColor: context.getColor(ThemeEnum.hintColor),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
