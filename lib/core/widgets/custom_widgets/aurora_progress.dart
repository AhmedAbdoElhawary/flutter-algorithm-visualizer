import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The one progress bar — XP bar, difficulty bars, step progress. A solid fill,
/// start-edge anchored, on a recessed [GlassTrack]. Heights in use are 4 / 5 / 6
/// / 7; the fill role is semantic (white for XP / steps, the difficulty hue for
/// difficulty rows) — never a raw colour.
class AuroraProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final ThemeEnum fill;

  const AuroraProgressBar({
    super.key,
    required this.value,
    this.height = 6,
    this.fill = ThemeEnum.accentXp,
  });

  @override
  Widget build(BuildContext context) {
    return GlassTrack(
      height: height,
      child: FractionallySizedBox(
        alignment: AlignmentDirectional.centerStart,
        widthFactor: value.clamp(0.0, 1.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.getColor(fill),
            borderRadius: BorderRadius.circular(CdRadius.pill.r),
          ),
        ),
      ),
    );
  }
}
