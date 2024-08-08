import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({
    this.color = ThemeEnum.whiteD4Color,
    this.withHeight = true,
    this.thickness,
    super.key,
  });
  final ThemeEnum color;
  final bool withHeight;
  final double? thickness;
  @override
  Widget build(BuildContext context) {
    return Divider(
      color: context.getColor(color),
      height: withHeight ? 4.r : 0,
      thickness: thickness,
    );
  }
}

class WideCustomDivider extends StatelessWidget {
  const WideCustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomDivider(color: ThemeEnum.whiteD1Color, thickness: 5);
  }
}
