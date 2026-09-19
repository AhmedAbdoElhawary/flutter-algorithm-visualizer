import 'package:algorithm_visualizer/core/localization/app_localizations.dart';
import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/styles_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/ltr_content.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// CoreDive auth field (screens 11 / 12 / 13).
///
/// Label (500 11) 7px above; box bg [ThemeEnum.surface], 1px [ThemeEnum.hairline],
/// radius md, 13/14 padding, 15px leading icon. Focus → teal border + 3px ring,
/// icon turns [ThemeEnum.inkTitle]. Error → clay border + 3px ring, message
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
        ? ThemeEnum.dataHard
        : _focused
            ? ThemeEnum.inkPrimary
            : ThemeEnum.hairline;

    final iconColor = hasError
        ? ThemeEnum.dataHard
        : _focused
            ? ThemeEnum.inkTitle
            : ThemeEnum.inkThirdTitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MediumText(widget.label, color: ThemeEnum.inkSecondaryTitle, fontSize: 11, maxLines: 1),
            if (widget.trailingLabelWidget != null) widget.trailingLabelWidget!,
          ],
        ),
        SizedBox(height: 7.h),
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.getColor(ThemeEnum.surface),
            borderRadius: BorderRadius.circular(CdRadius.sm.r),
            border: Border.all(color: context.getColor(borderColor)),
          ),
          child: SymmetricPadding(
            horizontal: 14,
            vertical: 16,
            child: Row(
              children: [
                if (widget.prefixIcon != null) ...[
                  CustomIcon(widget.prefixIcon!, size: 15, color: iconColor),
                  SizedBox(width: 10.w),
                ],

                /// An email address and a password are Latin by definition,
                /// so the field they are typed into does not mirror. Left to
                /// the page's direction, an Arabic user would get a caret on
                /// the right, a right-aligned hint, and `@example.com`
                /// reordered around the `@` as they typed.
                Expanded(
                  child: _LatinInput(
                    enabled: widget.isPassword || widget.keyboardType == TextInputType.emailAddress,
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _node,
                      keyboardType: widget.keyboardType,
                      textInputAction: widget.textInputAction,
                      obscureText: obscured,
                      onChanged: widget.onChanged,
                      onSubmitted: widget.onSubmitted,
                      cursorColor: context.getColor(ThemeEnum.inkPrimary),
                      style: const GetMediumStyle().copyWith(
                        color: context.getColor(ThemeEnum.inkPrimary),
                        fontSize: (obscured ? 13 : 12.5).sp,
                        letterSpacing: obscured ? 1.8.sp : 0.2,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: widget.hintText.tr(context),
                        hintStyle: const GetMediumStyle().copyWith(
                          color: context.getColor(ThemeEnum.inkThirdTitle),
                          fontSize: 12.5.sp,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                if (widget.isPassword)
                  GestureDetector(
                    onTap: widget.onTogglePasswordVisibility,
                    child: CustomIcon(
                      widget.isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 15,
                      color: ThemeEnum.inkThirdTitle,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (hasError)
          TopPadding(
            padding: 6,
            child: RegularText(widget.errorText!, color: ThemeEnum.dataHard, fontSize: 10.5),
          ),

        // else if (widget.helperText != null && widget.helperText!.isNotEmpty)
        //   TopPadding(
        //     padding: 8,
        //     child: RegularText(widget.helperText!, color: ThemeEnum.inkMuted, fontSize: 10.5),
        //   ),
      ],
    );
  }
}

/// [LtrContent], but only when [enabled] — so one call site can say "this
/// input is Latin" without an `if` around the whole field.
class _LatinInput extends StatelessWidget {
  const _LatinInput({required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) => enabled ? LtrContent(child: child) : child;
}
