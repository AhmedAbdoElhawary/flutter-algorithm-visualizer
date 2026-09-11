import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Back arrow, transport controls, header actions, the Visualizer's play
/// control — a 32px/44px square, radius scaling with size. [filled] swaps
/// the default 1px `border subtle` outline for a solid `textBright` fill
/// with an `onPrimary` icon (the one 44px play button, no glow).
class IconButtonQuiet extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final bool filled;

  const IconButtonQuiet({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 32,
    this.iconSize = 16,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.r,
        height: size.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? context.getColor(ThemeEnum.textBright) : null,
          borderRadius: BorderRadius.circular((size >= 44 ? 14 : 10).r),
          border: filled ? null : Border.all(color: context.getColor(ThemeEnum.borderSubtle)),
        ),
        child: CustomIcon(
          icon,
          size: iconSize,
          color: filled
              ? ThemeEnum.onPrimary
              : disabled
                  ? ThemeEnum.textDisabled
                  : ThemeEnum.textBody,
        ),
      ),
    );
  }
}
