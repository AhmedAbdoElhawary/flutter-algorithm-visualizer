import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAssetsSvg extends StatelessWidget {
  const CustomAssetsSvg(
    this.path, {
    this.size,
    this.semanticLabel,
    this.color = ThemeEnum.focusColor,
    super.key,
  });
  final String path;
  final String? semanticLabel;
  final double? size;
  final ThemeEnum? color;
  @override
  Widget build(BuildContext context) {
    final color = this.color;
    final size = this.size;
    if (path.isEmpty) return const RSizedBox();

    return SvgPicture.asset(
      path,
      height: size?.r,
      semanticsLabel: semanticLabel,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(context.getColor(color), BlendMode.srcIn),
    );
  }
}
