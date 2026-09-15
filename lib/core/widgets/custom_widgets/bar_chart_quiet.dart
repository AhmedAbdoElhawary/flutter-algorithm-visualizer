import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum BarState { sorted, excluded, key, swap, comparing, idle }

ThemeEnum barStateRole(BarState state) => switch (state) {
      BarState.sorted => ThemeEnum.dataEasy,
      BarState.excluded => ThemeEnum.raised,
      BarState.key => ThemeEnum.dataActive,
      BarState.swap => ThemeEnum.dataHard,
      BarState.comparing => ThemeEnum.dataActive,
      BarState.idle => ThemeEnum.track,
    };

class BarChartBar {
  final double value;
  final double max;
  final BarState state;
  final String? label;

  const BarChartBar({required this.value, required this.max, this.state = BarState.idle, this.label});
}

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
        borderRadius: BorderRadius.circular(CdRadius.tiny.r),
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
                color: bar.state == BarState.sorted ? ThemeEnum.dataEasy : ThemeEnum.inkTitle,
              ),
            ),
          ),
          const RSizedBox(height: 4),
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
                borderRadius: BorderRadius.circular(CdRadius.tiny.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
