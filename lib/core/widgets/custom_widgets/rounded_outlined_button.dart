import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum OutlineEnumFixedSize { small, non }

class RoundedOutlinedButton extends StatelessWidget {
  final ThemeEnum? backgroundColor;
  final Widget child;
  final VoidCallback? onPressed;
  final OutlineEnumFixedSize size;
  final ThemeEnum borderColor;
  final bool smallRounded;
  const RoundedOutlinedButton({
    super.key,
    this.smallRounded = false,
    this.backgroundColor,
    this.size = OutlineEnumFixedSize.small,
    this.borderColor = ThemeEnum.hintColor,
    required this.child,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    final backgroundColor = this.backgroundColor;
    final background =
        backgroundColor == null ? null : context.getColor(backgroundColor);

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor:
            backgroundColor == null ? null : context.getColor(backgroundColor),
        fixedSize: size == OutlineEnumFixedSize.small
            ? Size.fromHeight(smallRounded ? 30.h : 35.h)
            : null,
        padding: REdgeInsets.symmetric(horizontal: 15),
        surfaceTintColor: background,
        foregroundColor: context.getColor(ThemeEnum.hintColor),
        side: BorderSide(color: context.getColor(borderColor), width: 1.5.r),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(smallRounded ? 5 : 50)),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
