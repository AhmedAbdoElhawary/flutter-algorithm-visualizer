import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Back arrow, transport controls, header actions, the Visualizer's play
/// control — a 32px/44px square, radius scaling with size. [filled] swaps
/// the default 1px `border subtle` outline for a solid `textBright` fill
/// with an `ground` icon (the one 44px play button, no glow).
class IconButtonQuiet extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final bool filled;

  /// Semantic override for the icon's own ink role (e.g. the destructive
  /// "log out" row) — a [ThemeEnum] role, never a raw `Color`.
  final ThemeEnum? iconColor;
  final ThemeEnum? borderColor;
  final ThemeEnum? filledColor;

  /// Forwarded to [CustomIcon.flipsWithDirection] — set it for a back caret
  /// or any other icon that points.
  final bool flipsWithDirection;

  const IconButtonQuiet({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 32,
    this.iconSize = 16,
    this.filled = false,
    this.iconColor,
    this.borderColor,
    this.filledColor,
    this.flipsWithDirection = false,
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
          color: filled ? context.getColor(filledColor ?? ThemeEnum.inkPrimary) : null,
          borderRadius: BorderRadius.circular((size >= 44 ? 14 : 10).r),
          border: filled ? null : Border.all(color: context.getColor(borderColor ?? ThemeEnum.track)),
        ),
        child: CustomIcon(
          icon,
          size: iconSize,
          color: iconColor ??
              (filled ? ThemeEnum.ground : (disabled ? ThemeEnum.track : ThemeEnum.inkSecondaryTitle)),
          flipsWithDirection: flipsWithDirection,
        ),
      ),
    );
  }
}
