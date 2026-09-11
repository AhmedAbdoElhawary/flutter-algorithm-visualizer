import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// CoreDive primary action. Solid teal, full-opacity ink label (never white at
/// alpha), glow. Press = [ThemeEnum.primaryPress] + 0.98 scale over 90ms.
/// Disabled = [ThemeEnum.surfaceAlt] / [ThemeEnum.textDisabled], no shadow.
class AuthPrimaryButton extends StatefulWidget {
  final String title;
  final VoidCallback? onPressed;
  final bool isLoading;

  /// Kept for source compatibility; CoreDive buttons carry no trailing icon.
  final IconData? icon;

  const AuthPrimaryButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  State<AuthPrimaryButton> createState() => _AuthPrimaryButtonState();
}

class _AuthPrimaryButtonState extends State<AuthPrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.isLoading;

    final bg = disabled
        ? ThemeEnum.surfaceAlt
        : _pressed
            ? ThemeEnum.primaryPress
            : ThemeEnum.accent;
    final fg = disabled ? ThemeEnum.textDisabled : ThemeEnum.onPrimary;

    return GestureDetector(
      onTap: disabled ? null : widget.onPressed,
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
      onTapCancel: disabled ? null : () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? CdMotion.pressScale : 1,
        duration: CdMotion.press,
        child: AnimatedContainer(
          duration: CdMotion.press,
          padding: REdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: context.getColor(bg),
            borderRadius: BorderRadius.circular(CdRadius.md.r),
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 18.r,
                    height: 18.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2.r,
                      valueColor: AlwaysStoppedAnimation<Color>(context.getColor(ThemeEnum.onPrimary)),
                    ),
                  )
                : SemiBoldText(widget.title, color: fg, fontSize: 14, maxLines: 1),
          ),
        ),
      ),
    );
  }
}
