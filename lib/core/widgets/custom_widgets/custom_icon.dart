import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomIcon extends StatelessWidget {
  const CustomIcon(
    this.icon, {
    this.size = 22,
    this.color,
    this.shadows,
    this.flipsWithDirection = false,
    super.key,
  });
  final IconData icon;
  final ThemeEnum? color;
  final double size;
  final List<Shadow>? shadows;

  /// Set this for an icon that *points* — a chevron into a row, a back
  /// caret, a "next" arrow. In Arabic those all have to point the other way.
  ///
  /// Material only auto-mirrors a handful of icons, and none of the rounded
  /// variants this app uses, so the flip is done here with a transform. That
  /// also means one flag covers every pointing icon instead of each call site
  /// having to know the name of its own mirror image.
  final bool flipsWithDirection;

  @override
  Widget build(BuildContext context) {
    final glyph = Icon(
      icon,

      /// Falls back to a *role*, never a literal: the previous default was
      /// `ColorManager.groundDk`, which would have drawn a near-black icon on
      /// a near-black page.
      color: context.getColor(color ?? ThemeEnum.inkTitle),
      size: size.r,
      shadows: shadows,
    );

    if (!flipsWithDirection || Directionality.of(context) == TextDirection.ltr) {
      return glyph;
    }
    return Transform.flip(flipX: true, child: glyph);
  }
}
