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

  const SecondaryButtonQuiet({
    super.key,
    required this.label,
    required this.onPressed,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: expand ? double.infinity : null,
        padding: REdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: context.getColor(ThemeEnum.borderStrong)),
        ),
        child: SemiBoldText(label, color: ThemeEnum.textPrimary, fontSize: 13.5),
      ),
    );
  }
}
