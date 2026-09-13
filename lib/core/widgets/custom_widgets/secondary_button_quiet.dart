import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Outlined CTA — Reset, "See the visual trace" — 1px `border strong`, no
/// fill.
class SecondaryButtonQuiet extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool expand;
  final ThemeEnum borderColor;
  final double horizontalInnerPadding;
  const SecondaryButtonQuiet({
    super.key,
    required this.label,
    required this.onPressed,
    this.horizontalInnerPadding = 0,
    this.expand = true,
    this.borderColor = ThemeEnum.borderStrong,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: expand ? double.infinity : null,
        padding: REdgeInsets.symmetric(vertical: 14, horizontal: horizontalInnerPadding),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.getColor(ThemeEnum.primary),
          borderRadius: BorderRadius.circular(CdRadius.md.r),
          border: Border.all(color: context.getColor(borderColor)),
        ),
        child: SemiBoldText(label, color: ThemeEnum.textPrimary, fontSize: 13.5),
      ),
    );
  }
}
