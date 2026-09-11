import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// One bar's resolved render state, in the fixed priority order the caller
/// must apply (Contract 4): sorted > excluded > key > swap > comparing > idle.
/// `key` and `comparing` share one role — white/[ThemeEnum.comparing] — so the
/// caller's caption is what disambiguates them; this widget carries no
/// per-bar identity beyond the resolved state.
enum BarState { sorted, excluded, key, swap, comparing, idle }

ThemeEnum barStateRole(BarState state) => switch (state) {
      BarState.sorted => ThemeEnum.barDone,
      BarState.excluded => ThemeEnum.barExcluded,
      BarState.key => ThemeEnum.comparing,
      BarState.swap => ThemeEnum.barSwap,
      BarState.comparing => ThemeEnum.comparing,
      BarState.idle => ThemeEnum.barIdle,
    };

class BarChartBar {
  final double value;
  final double max;
  final BarState state;
  final String? label;

  const BarChartBar({required this.value, required this.max, this.state = BarState.idle, this.label});
}

/// One implementation for both the Visualizer plot and the Home sparkline.
/// Per column: a fixed-height label row (skipped when [compact]), then the
/// bar in its own flexible track aligned to the bottom — the `value / max`
/// fraction always resolves against [trackHeight] alone, never against
/// label + gap + bar (FR-015).
class BarChartQuiet extends StatelessWidget {
  final List<BarChartBar> bars;
  final double trackHeight;
  final bool compact;
  final double gap;

  const BarChartQuiet({
    super.key,
    required this.bars,
    required this.trackHeight,
    this.compact = false,
    this.gap = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (int i = 0; i < bars.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(end: i == bars.length - 1 ? 0 : gap.w),
              child: _Bar(bar: bars[i], trackHeight: trackHeight, compact: compact),
            ),
          ),
      ],
    );
  }
}

/// A single Quiet bar rectangle — the colour/radius primitive [BarChartQuiet]
/// composes internally, exposed separately for call sites (the sorting
/// visualizer) that drive their own per-item layout/position animation and
/// only need the bar's fill. [fill] is the resolved [ThemeEnum] role, not a
/// raw `Color` — the same semantic-token pattern the domain layer's own
/// `SortableItem.getColor` already produces.
class QuietBar extends StatelessWidget {
  final double width;
  final double height;
  final ThemeEnum fill;

  const QuietBar({super.key, required this.width, required this.height, required this.fill});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: CdMotion.barHeight,
      curve: CdMotion.easeOut,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.getColor(fill),
        borderRadius: BorderRadius.circular(3.r),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final BarChartBar bar;
  final double trackHeight;
  final bool compact;

  const _Bar({required this.bar, required this.trackHeight, required this.compact});

  @override
  Widget build(BuildContext context) {
    final fraction = bar.max <= 0 ? 0.0 : (bar.value / bar.max).clamp(0.0, 1.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!compact) ...[
          SizedBox(
            height: 14.h,
            child: Center(
              child: MediumText(
                bar.label ?? bar.value.toStringAsFixed(0),
                fontSize: 10,
                color: bar.state == BarState.sorted ? ThemeEnum.difficultyEasy : ThemeEnum.textPrimary,
              ),
            ),
          ),
          RSizedBox(height: 4),
        ],
        SizedBox(
          height: trackHeight,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: CdMotion.barHeight,
              curve: CdMotion.easeOut,
              width: double.infinity,
              height: trackHeight * fraction,
              decoration: BoxDecoration(
                color: context.getColor(barStateRole(bar.state)),
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
