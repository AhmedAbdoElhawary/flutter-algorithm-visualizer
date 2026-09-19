import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/search_role.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/widgets/end_point.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/widgets/start_point.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PFLegend extends StatelessWidget {
  const PFLegend({this.horizontalPadding=16, this.spacing=12,super.key});
final double spacing;
final double horizontalPadding;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: OnlyPadding(
        startPadding: horizontalPadding,
        endPadding: horizontalPadding,
        topPadding: 8,
        child: Wrap(
          spacing: spacing.w,
          runSpacing: 4.h,
          alignment: WrapAlignment.center,
          children: [
            for (final role in kSearchRolePriority) _PFLegendChip(role: role),
          ],
        ),
      ),
    );
  }
}

class _PFLegendChip extends StatelessWidget {
  const _PFLegendChip({required this.role});

  final SearchRole role;

  @override
  Widget build(BuildContext context) {
    final color = context.getColor(searchRoleColor(role));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PFLegendSwatch(role: role, color: color),
        const RSizedBox(width: 4),
        RegularText(searchRoleLabel(role), color: ThemeEnum.inkSecondaryTitle, fontSize: 10),
      ],
    );
  }
}

class _PFLegendSwatch extends StatelessWidget {
  const _PFLegendSwatch({required this.role, required this.color});

  final SearchRole role;
  final Color color;

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case SearchRole.start:
        return PFStartPointWidget(size: 10.r, color: color);
      case SearchRole.end:
        return PFEndPointWidget(
          size: 12.r,
          outerColor: color,
          midColor: context.getColor(ThemeEnum.inkPrimary),
          innerColor: color,
        );
      case SearchRole.path:
      case SearchRole.searcher:
      case SearchRole.visited:
      case SearchRole.wall:
        return Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        );
    }
  }
}
