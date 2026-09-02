import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthPrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const AuthPrimaryButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48.r,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.centerStart,
            end: AlignmentDirectional.centerEnd,
            colors: isDisabled
                ? [
                    context.getColor(ThemeEnum.accent).withValues(alpha: 0.5),
                    context.getColor(ThemeEnum.pink).withValues(alpha: 0.5),
                  ]
                : [
                    context.getColor(ThemeEnum.accent),
                    context.getColor(ThemeEnum.pink).withValues(alpha: 0.9),
                  ],
          ),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: isDisabled
              ? []
              : [
                  BoxShadow(
                    color: context.getColor(ThemeEnum.accent).withValues(alpha: 0.35),
                    blurRadius: 16,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 20.r,
                  height: 20.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2.r,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      context.getColor(ThemeEnum.solidWhite),
                    ),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SemiBoldText(
                      title,
                      color: ThemeEnum.solidWhite,
                      fontSize: 15,
                    ),
                    if (icon != null) ...[
                      RSizedBox(width: 8),
                      CustomIcon(
                        icon!,
                        size: 16,
                        color: ThemeEnum.solidWhite,
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
