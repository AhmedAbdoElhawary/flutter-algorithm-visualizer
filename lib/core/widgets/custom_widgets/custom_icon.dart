import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomIcon extends StatelessWidget {
  const CustomIcon(
    this.icon, {
    this.size = 22,
    this.color,
    this.shadows,
    super.key,
  });
  final IconData icon;
  final ThemeEnum? color;
  final double size;
  final List<Shadow>? shadows;
  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,

      /// Falls back to a *role*, never a literal: the previous default was
      /// `ColorManager.groundDk`, which would have drawn a near-black icon on
      /// a near-black page.
      color: context.getColor(color ?? ThemeEnum.inkTitle),
      size: size.r,
      shadows: shadows,
    );
  }
}
