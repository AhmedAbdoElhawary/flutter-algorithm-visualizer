import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomIcon extends StatelessWidget {
  const CustomIcon(
    this.icon, {
    this.size = 22,
    this.color = ThemeEnum.focusColor,
    this.shadows,
    super.key,
  });
  final IconData icon;
  final ThemeEnum color;
  final double size;
  final List<Shadow>? shadows;
  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      color: context.getColor(color),
      size: size.r,
      shadows: shadows,
    );
  }
}
