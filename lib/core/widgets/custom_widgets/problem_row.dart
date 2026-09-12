import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The shared list-row decoration for Practice, Bookmarks, and History —
/// built on [CardContainer] at [CdSurface.main]. A [selected] (expanded) row
/// steps its border to `border strong` by stacking an overlay border on top,
/// since [CardContainer] has no border-colour override of its own and its
/// inner border would otherwise repaint over a same-rect outer border. The
/// row's own content is passed as [child].
class ProblemRow extends StatelessWidget {
  final Widget child;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongTap;
  final EdgeInsetsGeometry padding;

  const ProblemRow({
    super.key,
    required this.child,
    this.selected = false,
    this.onTap,
    this.onLongTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
  });

  @override
  Widget build(BuildContext context) {
    Widget row = CardContainer(
      surface: CdSurface.main,
      radius: CdRadius.md,
      padding: padding,
      child: child,
    );
    if (selected) {
      row = Stack(
        children: [
          row,
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(CdRadius.md.r),
                  border: Border.all(color: context.getColor(ThemeEnum.borderStrong)),
                ),
              ),
            ),
          ),
        ],
      );
    }
    if (onTap == null && onLongTap == null) return row;
    return GestureDetector(
        onTap: onTap, onLongPress: onLongTap, behavior: HitTestBehavior.opaque, child: row);
  }
}
