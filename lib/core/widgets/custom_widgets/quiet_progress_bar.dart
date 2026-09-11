import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The one 3px-height progress bar — XP, difficulty, step progress, the
/// live-session row, the celebration level bar. [track] is the background
/// rail (defaults to [ThemeEnum.track]); [fill] is the filled portion
/// (defaults to the primary ink/action role).
class QuietProgressBar extends StatelessWidget {
  final double value;
  final ThemeEnum fill;
  final ThemeEnum track;

  const QuietProgressBar({
    super.key,
    required this.value,
    this.fill = ThemeEnum.textBright,
    this.track = ThemeEnum.track,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(CdRadius.hairlinePill.r),
      child: Container(
        height: 3.h,
        color: context.getColor(track),
        alignment: AlignmentDirectional.centerStart,
        child: FractionallySizedBox(
          alignment: AlignmentDirectional.centerStart,
          widthFactor: value.clamp(0, 1),
          child: Container(color: context.getColor(fill)),
        ),
      ),
    );
  }
}
