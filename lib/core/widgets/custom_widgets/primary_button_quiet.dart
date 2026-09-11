import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Every filled CTA — solid `textBright` (primary ink/action role) fill,
/// `onPrimary` label, no glow. [expand] makes it fill the row's width.
class PrimaryButtonQuiet extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool expand;
  final bool loading;

  const PrimaryButtonQuiet({
    super.key,
    required this.label,
    required this.onPressed,
    this.expand = true,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;
    final button = GestureDetector(
      onTap: disabled ? null : onPressed,
      child: Container(
        width: expand ? double.infinity : null,
        padding: REdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.getColor(ThemeEnum.textBright),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: loading
            ? SizedBox(
                width: 18.r,
                height: 18.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.getColor(ThemeEnum.onPrimary),
                ),
              )
            : SemiBoldText(label, color: ThemeEnum.onPrimary, fontSize: 13.5),
      ),
    );
    return disabled ? Opacity(opacity: 0.5, child: button) : button;
  }
}
