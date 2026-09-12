import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Sorting progress rail. CoreDive keeps gradients to two places (XP fill and the
/// auth wash), so this is a solid teal fill on a [ThemeEnum.surfaceAlt] track,
/// anchored to the start edge.
class GradientLinearProgressIndicator extends StatelessWidget {
  final double value;

  const GradientLinearProgressIndicator({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(CdRadius.pill.r),
      child: RSizedBox(
        height: 3,
        child: Stack(
          children: [
            Container(color: context.getColor(ThemeEnum.hover)),
            FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(color: context.getColor(ThemeEnum.accent)),
            ),
          ],
        ),
      ),
    );
  }
}
