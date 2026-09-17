import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/features/onboarding/widgets/onboarding_card.dart';
import 'package:algorithm_visualizer/features/onboarding/widgets/onboarding_text.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// One comparison in the scripted run: the two positions being looked at,
/// whether they swap, and the position that is finished afterwards.
class _Step {
  const _Step(this.i, this.j, {this.swap = false, this.settles});

  final int i;
  final int j;
  final bool swap;
  final int? settles;
}

/// Screen 1 · See it — eight bars running a scripted bubble-sort pass.
///
/// The script is fixed rather than generated so the loop always reads the
/// same: ten comparisons at 600 ms each is the ~6 s loop the spec asks for.
class SortingVisual extends StatefulWidget {
  const SortingVisual({required this.isActive, super.key});

  /// True while this page is the visible one. The controller is stopped
  /// otherwise so an off-screen page costs nothing.
  final bool isActive;

  @override
  State<SortingVisual> createState() => _SortingVisualState();
}

class _SortingVisualState extends State<SortingVisual> with SingleTickerProviderStateMixin {
  static const List<int> _values = [6, 14, 9, 4, 11, 16, 7, 12];
  static const int _maxValue = 18;

  static const List<_Step> _steps = [
    _Step(0, 1),
    _Step(1, 2, swap: true),
    _Step(2, 3, swap: true),
    _Step(3, 4, swap: true),
    _Step(4, 5),
    _Step(5, 6, swap: true),
    _Step(6, 7, swap: true, settles: 7),
    _Step(0, 1),
    _Step(1, 2, swap: true),
    _Step(2, 3),
  ];

  /// Share of a step spent on the 280 ms compare before the 320 ms swap.
  static const double _comparePhase = 280 / 600;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 600 * _steps.length),
  );

  /// The order of value indices at the *start* of each step, plus one final
  /// entry for the state the loop ends on. Precomputed once — replaying the
  /// swaps on every frame would be wasted work.
  late final List<List<int>> _orders = _buildOrders();

  List<List<int>> _buildOrders() {
    final orders = <List<int>>[];
    var current = List<int>.generate(_values.length, (index) => index);
    for (final step in _steps) {
      orders.add(List<int>.of(current));
      if (step.swap) {
        current = List<int>.of(current);
        final temp = current[step.i];
        current[step.i] = current[step.j];
        current[step.j] = temp;
      }
    }
    orders.add(current);
    return orders;
  }

  @override
  void didUpdateWidget(SortingVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  void _sync() {
    // Accessibility: with animations off the visual holds its final frame
    // instead of moving (spec §1).
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 1;
      return;
    }
    if (widget.isActive) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doneColor = sortingRoleColor(SortRole.sorted);
    final compareColor = sortingRoleColor(SortRole.compare);
    final swapColor = sortingRoleColor(SortRole.swap);
    final idleColor = sortingRoleColor(SortRole.idle);

    final idle = context.getColor(idleColor);
    final compare = context.getColor(compareColor);
    final swap = context.getColor(swapColor);
    final done = context.getColor(doneColor);

    return OnboardingCard(
      child: OnlyPadding(
        startPadding: 18,
        endPadding: 18,
        topPadding: 20,
        bottomPadding: 16,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final progress = _controller.value;
            final exact = (progress * _steps.length).clamp(0.0, _steps.length.toDouble());
            final index = exact.floor().clamp(0, _steps.length - 1);
            final phase = (exact - index).clamp(0.0, 1.0);
            final step = _steps[index];
            final order = _orders[index];

            final bars = <_BarFrame>[];
            for (var position = 0; position < order.length; position++) {
              final isPair = position == step.i || position == step.j;
              final isSwapping = isPair && step.swap && phase > _comparePhase;

              var slot = position.toDouble();
              if (isSwapping) {
                final t = ((phase - _comparePhase) / (1 - _comparePhase)).clamp(0.0, 1.0);
                final eased = Curves.easeInOut.transform(t);
                final target = position == step.i ? step.j : step.i;
                slot = position + (target - position) * eased;
              }

              bars.add(
                _BarFrame(
                  height: _values[order[position]] / _maxValue,
                  slot: slot,
                  lift: isPair ? 6 * _liftCurve(phase) : 0,
                  color: _settled(index, position)
                      ? done
                      : isPair
                          ? (isSwapping ? swap : compare)
                          : idle,
                ),
              );
            }

            final left = _values[order[step.i]];
            final right = _values[order[step.j]];

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 200.h,
                  width: double.infinity,
                  child: CustomPaint(painter: _BarsPainter(bars)),
                ),
                SizedBox(height: 16.h),
                OnboardingLegend(
                  items: [
                    LegendItem(
                      color: compareColor,
                      label: StringsManager.onboardingLegendCompare,
                    ),
                    LegendItem(
                      color: swapColor,
                      label: StringsManager.onboardingLegendSwap,
                    ),
                    LegendItem(
                      color: doneColor,
                      label: StringsManager.onboardingLegendSorted,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                OnboardingCaptionBar(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FadeTransition(
                        // Cross-fade in at the start of every comparison.
                        // `FadeTransition` rather than `Opacity`: this is
                        // recomputed on every frame of the sorting loop, and
                        // `Opacity` would `saveLayer` each time.
                        opacity: AlwaysStoppedAnimation<double>((phase / 0.12).clamp(0.0, 1.0)),
                        child: MonoText(
                          StringsManager.onboardingCompareCaption(context, step.i, left, step.j, right),
                          color: ThemeEnum.inkTitle,
                        ),
                      ),
                      SizedBox(height: 9.h),
                      _ProgressTrack(progress: progress),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Up over the first quarter of the step, held, back down at the end.
  /// Clamped on both ends: at the very last frame `phase` lands a hair over 1
  /// and [Curve.transform] asserts on anything outside [0, 1].
  double _liftCurve(double phase) {
    if (phase < 0.25) {
      return Curves.easeOut.transform((phase / 0.25).clamp(0.0, 1.0));
    }
    if (phase > 0.85) {
      return 1 - Curves.easeIn.transform(((phase - 0.85) / 0.15).clamp(0.0, 1.0));
    }
    return 1;
  }

  bool _settled(int stepIndex, int position) {
    for (var s = 0; s <= stepIndex; s++) {
      if (_steps[s].settles == position) return true;
    }
    return false;
  }
}

/// A single bar as it should be drawn this frame.
class _BarFrame {
  const _BarFrame({
    required this.height,
    required this.slot,
    required this.lift,
    required this.color,
  });

  /// 0-1 fraction of the available height.
  final double height;

  /// Fractional slot index, so a swapping pair can sit between two slots.
  final double slot;

  /// Logical pixels the bar is raised by.
  final double lift;

  final Color color;
}

class _BarsPainter extends CustomPainter {
  const _BarsPainter(this.bars);

  final List<_BarFrame> bars;

  static const double _gap = 8;
  static const double _radius = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final count = bars.length;
    final barWidth = (size.width - _gap * (count - 1)) / count;
    final pitch = barWidth + _gap;

    for (final bar in bars) {
      final height = size.height * bar.height;
      final rect = Rect.fromLTWH(
        bar.slot * pitch,
        size.height - height - bar.lift,
        barWidth,
        height,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(_radius)),
        Paint()..color = bar.color,
      );
    }
  }

  @override
  bool shouldRepaint(_BarsPainter oldDelegate) => true;
}

/// The 3 px run progress bar under the caption.
class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3.h,
      decoration: BoxDecoration(
        color: context.getColor(ThemeEnum.track),
        borderRadius: BorderRadius.circular(2.r),
      ),
      child: FractionallySizedBox(
        alignment: AlignmentDirectional.centerStart,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: context.getColor(ThemeEnum.inkPrimary),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ),
    );
  }
}
