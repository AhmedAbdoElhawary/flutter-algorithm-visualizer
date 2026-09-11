import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The one shared card decoration — `surface` fill, 1px `border subtle`,
/// radius 14. No shadow, blur, or sheen (Quiet theme).
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool clip;

  /// False for an outline-only panel (no `surface` fill) — the Visualizer's
  /// plot/grid panels, which sit directly on `background base`.
  final bool filled;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
    this.clip = false,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14.r);
    final decorated = Container(
      decoration: BoxDecoration(
        color: filled ? context.getColor(ThemeEnum.mainCard) : null,
        borderRadius: radius,
        border: Border.all(color: context.getColor(ThemeEnum.borderSubtle)),
      ),
      child: Padding(padding: padding, child: child),
    );
    final card = clip ? ClipRRect(borderRadius: radius, child: decorated) : decorated;
    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }
}
