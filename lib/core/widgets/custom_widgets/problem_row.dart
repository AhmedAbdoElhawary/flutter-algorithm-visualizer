import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The shared list-row decoration for Practice, Bookmarks, and History —
/// `surface` fill, 1px `border subtle`, radius 14, padding `13 x 14`. A
/// [selected] (expanded) row takes `border strong` instead of a shadow or a
/// brighter fill. The row's own content is passed as [child].
class ProblemRow extends StatelessWidget {
  final Widget child;
  final bool selected;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const ProblemRow({
    super.key,
    required this.child,
    this.selected = false,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
  });

  @override
  Widget build(BuildContext context) {
    final row = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: context.getColor(ThemeEnum.mainCard),
        borderRadius: BorderRadius.circular(CdRadius.md.r),
        border: Border.all(
          color: context.getColor(selected ? ThemeEnum.borderStrong : ThemeEnum.borderSubtle),
        ),
      ),
      child: child,
    );
    if (onTap == null) return row;
    return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: row);
  }
}
