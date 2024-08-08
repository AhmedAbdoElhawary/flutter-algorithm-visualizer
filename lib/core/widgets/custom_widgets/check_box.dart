import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomCheckBox extends StatelessWidget {
  const CustomCheckBox({
    required this.isSelected,
    this.size = 26,
    this.isCircle = true,
    this.withCheckIcon = false,
    super.key,
  });
  final bool isSelected;
  final bool isCircle;
  final bool withCheckIcon;
  final double size;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        color: ColorManager.transparent,
        border: Border.all(
            width: 1.5.r,
            color: isSelected
                ? context.getColor(ThemeEnum.focusColor)
                : context.getColor(ThemeEnum.whiteD5Color)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: isSelected ? 20 : 0,
          width: isSelected ? 20 : 0,
          decoration: BoxDecoration(
            color: isSelected ? context.getColor(ThemeEnum.focusColor) : null,
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          ),
          child: isSelected && withCheckIcon
              ? const CustomIcon(Icons.check_rounded,
                  color: ThemeEnum.whiteColor, size: 18)
              : null,
        ),
      ),
    );
  }
}
