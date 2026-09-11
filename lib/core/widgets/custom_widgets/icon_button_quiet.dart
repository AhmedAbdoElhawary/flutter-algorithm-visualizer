import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Back arrow, transport controls, header actions — a 1px `border subtle`
/// outlined square, 32px or 44px, radius scaling with size.
class IconButtonQuiet extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;

  const IconButtonQuiet({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 32,
    this.iconSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.r,
        height: size.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular((size >= 44 ? 14 : 10).r),
          border: Border.all(color: context.getColor(ThemeEnum.borderSubtle)),
        ),
        child: CustomIcon(icon, size: iconSize, color: ThemeEnum.textBody),
      ),
    );
  }
}
