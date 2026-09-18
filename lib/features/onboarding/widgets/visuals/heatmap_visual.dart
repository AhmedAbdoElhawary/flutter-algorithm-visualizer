import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/styles_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/onboarding/widgets/onboarding_card.dart';
import 'package:algorithm_visualizer/features/onboarding/widgets/onboarding_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// One filled day on the activity grid.
typedef _Day = ({int week, int row, double level});

/// Screen 4 · Track it — the activity grid fills week by week while the streak
/// counts up on the same clock.
class HeatmapVisual extends StatefulWidget {
  const HeatmapVisual({required this.isActive, super.key});

  final bool isActive;

  @override
  State<HeatmapVisual> createState() => _HeatmapVisualState();
}

class _HeatmapVisualState extends State<HeatmapVisual> with SingleTickerProviderStateMixin {
  static const int _weeks = 15;
  static const int _rows = 7;
  static const int _streak = 14;
  static const int _solved = 37;

  static const int _weekMs = 70;
  static const int _ringMs = 400;

  /// One day per week column, exactly as the design lays them out. The last
  /// entry is today — it lands last, at full strength, and holds a ring.
  static const List<_Day> _days = [
    (week: 0, row: 1, level: 0.3),
    (week: 1, row: 3, level: 0.55),
    (week: 2, row: 0, level: 0.3),
    (week: 3, row: 2, level: 0.8),
    (week: 4, row: 5, level: 0.55),
    (week: 5, row: 1, level: 0.8),
    (week: 6, row: 4, level: 0.3),
    (week: 7, row: 3, level: 1),
    (week: 8, row: 0, level: 0.55),
    (week: 9, row: 2, level: 0.8),
    (week: 10, row: 5, level: 0.3),
    (week: 11, row: 1, level: 1),
    (week: 12, row: 3, level: 0.8),
    (week: 13, row: 5, level: 0.55),
    (week: 14, row: 2, level: 1),
  ];

  static const int _fillMs = _weeks * _weekMs;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _fillMs + _ringMs),
  );

  @override
  void didUpdateWidget(HeatmapVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  void _sync() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 1;
      return;
    }
    // The grid fills once and stays filled — it is a result, not a loop.
    if (widget.isActive && !_controller.isAnimating && !_controller.isCompleted) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingCard(
      child: SymmetricPadding(
        horizontal: 18,
        vertical: 20,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final elapsed = _controller.value * _controller.duration!.inMilliseconds;
            final filledWeeks = (elapsed / _weekMs).floor().clamp(0, _weeks);
            final streak = (_streak * (filledWeeks / _weeks)).round();
            final ring = elapsed <= _fillMs ? 0.0 : (1 - (elapsed - _fillMs) / _ringMs).clamp(0.0, 1.0);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _StatsRow(streak: streak, solved: _solved),
                const RSizedBox(height: 15),
                _HeatGrid(filledWeeks: filledWeeks, ring: ring),
                const RSizedBox(height: 15),
                const _HeatLegend(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.streak, required this.solved});

  final int streak;
  final int solved;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Flexible so the two mono labels ellipsize rather than push the row
        // wider than the card on a narrow screen.
        Flexible(
          child: _StatBlock(
            value: streak,
            label: StringsManager.onboardingDayStreak,
            color: ThemeEnum.dataEasy,
            alignment: CrossAxisAlignment.start,
          ),
        ),
        Flexible(
          child: _StatBlock(
            value: solved,
            label: StringsManager.onboardingSolved,
            color: ThemeEnum.inkTitle,
            alignment: CrossAxisAlignment.end,
          ),
        ),
      ],
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.value,
    required this.label,
    required this.color,
    required this.alignment,
  });

  final int value;
  final String label;
  final ThemeEnum color;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        AdaptiveText(
          value.toString(),
          maxLines: 1,
          style: GetSemiBoldStyle(
            fontSize: 40,
            height: 1,
            color: context.getColor(color),
          ),
        ),
        const RSizedBox(height: 4),
        MonoText(label),
      ],
    );
  }
}

class _HeatGrid extends StatelessWidget {
  const _HeatGrid({required this.filledWeeks, required this.ring});

  final int filledWeeks;
  final double ring;

  static const double _gap = 4;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Cell size comes from the width we were given, then the height
        // follows — no fixed pitch anywhere.
        final gap = _gap.w;
        final cell =
            (constraints.maxWidth - gap * (_HeatmapVisualState._weeks - 1)) / _HeatmapVisualState._weeks;
        final height = cell * _HeatmapVisualState._rows + gap * (_HeatmapVisualState._rows - 1);

        return SizedBox(
          width: constraints.maxWidth,
          height: height,
          child: CustomPaint(
            painter: _HeatPainter(
              days: _HeatmapVisualState._days,
              filledWeeks: filledWeeks,
              ring: ring,
              gap: gap,
              cell: cell,
              color: context.getColor(ThemeEnum.dataEasy),
              radius: 3.r,
            ),
          ),
        );
      },
    );
  }
}

class _HeatPainter extends CustomPainter {
  const _HeatPainter({
    required this.days,
    required this.filledWeeks,
    required this.ring,
    required this.gap,
    required this.cell,
    required this.color,
    required this.radius,
  });

  final List<_Day> days;
  final int filledWeeks;
  final double ring;
  final double gap;
  final double cell;
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    for (final day in days) {
      if (day.week >= filledWeeks) continue;
      final rect = Rect.fromLTWH(
        day.week * (cell + gap),
        day.row * (cell + gap),
        cell,
        cell,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        Paint()..color = color.withValues(alpha: day.level),
      );

      // Today holds a 2 px ring for 400 ms after it lands.
      if (ring > 0 && day == days.last) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.inflate(3), Radius.circular(radius + 2)),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = color.withValues(alpha: ring),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_HeatPainter oldDelegate) =>
      oldDelegate.filledWeeks != filledWeeks || oldDelegate.ring != ring;
}

class _HeatLegend extends StatelessWidget {
  const _HeatLegend();

  static const List<double> _levels = [0.3, 0.55, 0.8, 1];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const MonoText(StringsManager.onboardingHeatLess),
        SizedBox(width: 10.w),
        for (final level in _levels)
          EndPadding(
            padding: 4,
            child: Container(
              width: 10.r,
              height: 10.r,
              decoration: BoxDecoration(
                color: context.getColor(ThemeEnum.dataEasy).withValues(alpha: level),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
        SizedBox(width: 6.w),
        const MonoText(StringsManager.onboardingHeatMore),
      ],
    );
  }
}
