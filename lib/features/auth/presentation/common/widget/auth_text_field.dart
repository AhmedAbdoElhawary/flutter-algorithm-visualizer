import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/styles_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// CoreDive auth field (screens 11 / 12 / 13).
///
/// Label (500 11) 7px above; box bg [ThemeEnum.card], 1px [ThemeEnum.border],
/// radius md, 13/14 padding, 15px leading icon. Focus → teal border + 3px ring,
/// icon turns [ThemeEnum.primaryHover]. Error → clay border + 3px ring, message
/// below. Obscured passwords render in mono with wide tracking.
class AuthTextField extends StatefulWidget {
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
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  FocusNode? _ownNode;
  FocusNode get _node => widget.focusNode ?? (_ownNode ??= FocusNode());
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _node.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _node.removeListener(_onFocusChange);
    _ownNode?.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focused != _node.hasFocus) setState(() => _focused = _node.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final obscured = widget.isPassword && !widget.isPasswordVisible;

    final borderColor = hasError
        ? ThemeEnum.difficultyHard
        : _focused
            ? ThemeEnum.accent
            : ThemeEnum.border;

    final iconColor = hasError
        ? ThemeEnum.difficultyHard
        : _focused
            ? ThemeEnum.primaryHover
            : ThemeEnum.textDisabled;

    final ringColor = hasError
        ? context.getColor(ThemeEnum.errorRing)
        : _focused
            ? context.getColor(ThemeEnum.primaryRing)
            : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MediumText(widget.label, color: ThemeEnum.text2DarkColor, fontSize: 11, maxLines: 1),
            if (widget.trailingLabelWidget != null) widget.trailingLabelWidget!,
          ],
        ),
        SizedBox(height: 7.h),
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.getColor(ThemeEnum.card),
            borderRadius: BorderRadius.circular(CdRadius.md.r),
            border: Border.all(color: context.getColor(borderColor)),
            boxShadow: ringColor == null
                ? null
                : [BoxShadow(color: ringColor, spreadRadius: 3.r, blurRadius: 0)],
          ),
          child: SymmetricPadding(
            horizontal: 14,
            vertical: 13,
            child: Row(
              children: [
                if (widget.prefixIcon != null) ...[
                  CustomIcon(widget.prefixIcon!, size: 15, color: iconColor),
                  SizedBox(width: 10.w),
                ],
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _node,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    obscureText: obscured,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    cursorColor: context.getColor(ThemeEnum.accent),
                    style: GetMediumStyle().copyWith(
                      color: context.getColor(ThemeEnum.textBright),
                      fontSize: (obscured ? 13 : 12.5).sp,
                      letterSpacing: obscured ? 1.8.sp : 0.2,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: widget.hintText,
                      hintStyle: GetMediumStyle().copyWith(
                        color: context.getColor(ThemeEnum.textDisabled),
                        fontSize: 12.5.sp,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (widget.isPassword)
                  GestureDetector(
                    onTap: widget.onTogglePasswordVisibility,
                    child: CustomIcon(
                      widget.isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 15,
                      color: ThemeEnum.textDisabled,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (hasError)
          TopPadding(
            padding: 6,
            child: RegularText(widget.errorText!, color: ThemeEnum.difficultyHard, fontSize: 10.5),
          )
        else if (widget.helperText != null && widget.helperText!.isNotEmpty)
          TopPadding(
            padding: 8,
            child: RegularText(widget.helperText!, color: ThemeEnum.textDisabled, fontSize: 10.5),
          ),
      ],
    );
  }
}
