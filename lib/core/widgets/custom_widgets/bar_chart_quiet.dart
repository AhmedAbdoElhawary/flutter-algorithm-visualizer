import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuietBar extends StatelessWidget {
  final double width;
  final double height;
  final ThemeEnum fill;

  const QuietBar({super.key, required this.width, required this.height, required this.fill});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: CdMotion.barHeight,
      curve: CdMotion.easeOut,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.getColor(fill),
        borderRadius: BorderRadius.circular(CdRadius.tiny.r),
      ),
    );
  }
}
