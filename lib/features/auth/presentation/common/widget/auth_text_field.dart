import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/styles_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onTogglePasswordVisibility;
  final String? errorText;
  final String? helperText;
  final Widget? trailingLabelWidget;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.prefixIcon,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onTogglePasswordVisibility,
    this.errorText,
    this.helperText,
    this.trailingLabelWidget,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MediumText(
              label,
              color: ThemeEnum.textPrimary,
              fontSize: 13,
            ),
            if (trailingLabelWidget != null) trailingLabelWidget!,
          ],
        ),
        RSizedBox(height: 8),
        Container(
          height: 48.r,
          padding: REdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: context.getColor(ThemeEnum.card),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: hasError
                  ? context.getColor(ThemeEnum.accentRed)
                  : context.getColor(ThemeEnum.border),
              width: hasError ? 1.2.r : 1.r,
            ),
            boxShadow: context.cardShadow,
          ),
          child: Row(
            children: [
              if (prefixIcon != null) ...[
                CustomIcon(
                  prefixIcon!,
                  size: 18,
                  color: hasError ? ThemeEnum.accentRed : ThemeEnum.hover,
                ),
                RSizedBox(width: 12),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: keyboardType,
                  textInputAction: textInputAction,
                  obscureText: isPassword && !isPasswordVisible,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  style: GetMediumStyle(
                    color: context.getColor(ThemeEnum.textPrimary),
                    fontSize: 14,
                    letterSpacing: (isPassword && !isPasswordVisible) ? 1.5 : 0.2,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: context.getColor(ThemeEnum.textSecond),
                      fontSize: 14.r,
                      fontFamily: FontConstants.fontFamily,
                      letterSpacing: 0.2,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (isPassword)
                GestureDetector(
                  onTap: onTogglePasswordVisibility,
                  child: CustomIcon(
                    isPasswordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                    color: ThemeEnum.hover,
                  ),
                ),
            ],
          ),
        ),
        if (hasError)
          OnlyPadding(
            topPadding: 6,
            startPadding: 4,
            child: RegularText(
              errorText!,
              color: ThemeEnum.accentRed,
              fontSize: 12,
            ),
          )
        else if (helperText != null && helperText!.isNotEmpty)
          OnlyPadding(
            topPadding: 6,
            startPadding: 4,
            child: RegularText(
              helperText!,
              color: ThemeEnum.textSecond,
              fontSize: 12,
            ),
          ),
      ],
    );
  }
}
