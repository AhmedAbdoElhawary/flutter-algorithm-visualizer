import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The pinned action area — `background base` fill, 1px `border subtle` top
/// rule. No scrim, no glow.
class BottomCtaBar extends StatelessWidget {
  final Widget child;

  const BottomCtaBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: context.getColor(ThemeEnum.primary),
        border: Border(top: BorderSide(color: context.getColor(ThemeEnum.borderSubtle))),
      ),
      child: child,
    );
  }
}
