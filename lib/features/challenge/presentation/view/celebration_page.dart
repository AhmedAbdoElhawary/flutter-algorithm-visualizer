import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/localization/app_localizations.dart';
import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/primary_button_quiet.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/secondary_button_quiet.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/small_stats_strip.dart' show SmallStatsStrip;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Arguments for the solved-moment screen. XP / level / per-solve timing are not
/// modelled in the app yet, so only the real day streak is shown.
class CelebrationArgs {
  const CelebrationArgs({
    required this.problemName,
    required this.passedCount,
  });

  final String problemName;
  final int passedCount;
}

/// Aurora screen 14 — the solved moment. Full-screen over the same ground, no
/// nav. The entrance sequence is the only one in the app and yields to the OS
/// reduce-motion setting.
class CelebrationPage extends StatefulWidget {
  const CelebrationPage({super.key, required this.args});

  final CelebrationArgs args;

  @override
  State<CelebrationPage> createState() => _CelebrationPageState();
}

class _CelebrationPageState extends State<CelebrationPage> with TickerProviderStateMixin {
  late final AnimationController _rings = AnimationController(vsync: this, duration: CdMotion.ring)..repeat();
  late final AnimationController _entrance =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1150));

  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) {
      _rings.stop();
      _entrance.value = 1;
    } else if (!_entrance.isAnimating && _entrance.value == 0) {
      _entrance.forward();
    }
  }

  @override
  void dispose() {
    _rings.dispose();
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;

    return Scaffold(
      backgroundColor: context.getColor(ThemeEnum.ground),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              padding: REdgeInsets.fromLTRB(26, 100, 26, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _Stage(rings: _rings, reduceMotion: _reduceMotion),
                  _Rise(
                    controller: _entrance,
                    start: 0.15,
                    reduceMotion: _reduceMotion,
                    child: Padding(
                      padding: REdgeInsets.only(top: 32),
                      child: const BoldText(
                        StringsManager.solvedMoment,
                        color: ThemeEnum.inkTitle,
                        fontSize: 25,
                        letterSpacing: -0.5,
                        fontWeight: FontWeightManager.bold900,
                      ),
                    ),
                  ),
                  _Rise(
                    controller: _entrance,
                    start: 0.25,
                    reduceMotion: _reduceMotion,
                    child: Padding(
                      padding: REdgeInsets.only(top: 9),
                      child: RegularText(
                        '${args.problemName} · '
                        '${StringsManager.allNTestsPassedPrefix.tr(context)}'
                        '${args.passedCount}'
                        '${StringsManager.allNTestsPassedSuffix.tr(context)}',
                        color: ThemeEnum.inkSecondaryTitle,
                        fontSize: 12.5,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        // The problem's own name is inside this line.
                        translate: false,
                      ),
                    ),
                  ),
                  _Rise(
                    controller: _entrance,
                    start: 0.35,
                    reduceMotion: _reduceMotion,
                    child: Padding(
                      padding: REdgeInsets.only(top: 30),
                      child: const SmallStatsStrip(
                        showAttempts: false,
                        showIcons: false,
                        centerTheContent: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: 50.h,
              child: _Rise(
                controller: _entrance,
                start: 0.55,
                reduceMotion: _reduceMotion,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PrimaryButtonQuiet(
                      label: StringsManager.nextProblem,
                      onPressed: () => context.pushTo(Routes.practice),
                    ),
                    const RSizedBox(height: 10),
                    SecondaryButtonQuiet(
                      label: StringsManager.seeTheVisualTrace,
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stage extends StatelessWidget {
  const _Stage({required this.rings, required this.reduceMotion});

  final AnimationController rings;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final white = context.getColor(ThemeEnum.inkPrimary);
    return SizedBox(
      width: 140.r,
      height: 140.r,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (!reduceMotion) ...[
            _Ring(controller: rings, color: white, phase: 0),
            _Ring(controller: rings, color: white, phase: 0.33),
          ],
          _Checkmark(reduceMotion: reduceMotion),
        ],
      ),
    );
  }
}

/// Draws one expanding, fading ring straight onto the canvas.
///
/// The fade and the growth used to live in the widget tree, as an [Opacity]
/// wrapping a `Transform.scale` wrapping this painter, rebuilt by an
/// `AnimatedBuilder` on every frame. That cost an off-screen buffer
/// (`saveLayer`) per ring per frame on an animation that `repeat()`s and never
/// stops, with two rings on screen at once.
///
/// Both are geometry the painter can express directly: the fade is alpha on
/// the stroke colour, and the growth is the radius. The widget above is now
/// static and `repaint:` drives the canvas alone, so no widget rebuilds at all.
class _RingPainter extends CustomPainter {
  const _RingPainter({required this.animation, required this.color, required this.phase})
      : super(repaint: animation);

  final Animation<double> animation;
  final Color color;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final t = (animation.value + phase) % 1.0;

    /// What `Transform.scale` did to the whole box, applied to the two things
    /// in it that had a size: the radius and the stroke.
    final scale = 0.5 + t;

    final paint = Paint()
      ..color = color.withValues(alpha: (1 - t).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * scale;

    canvas.drawCircle(size.center(Offset.zero), size.shortestSide / 2 * scale, paint);
  }

  /// `false`, not `true`: [animation] is already wired to `repaint`, so the
  /// canvas is redrawn every frame regardless. Returning `true` here would
  /// only add a second, redundant reason to repaint.
  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.color != color || oldDelegate.phase != phase;
}

class _Ring extends StatelessWidget {
  const _Ring({required this.controller, required this.color, required this.phase});

  final AnimationController controller;
  final Color color;
  final double phase;

  @override
  Widget build(BuildContext context) {
    /// Keeps the two forever-animating rings off the celebration page's own
    /// layer, so the headline, the stats strip and the buttons behind them
    /// are not repainted sixty times a second along with the rings.
    return RepaintBoundary(
      child: SizedBox(
        width: 140.r,
        height: 140.r,
        child: CustomPaint(
          painter: _RingPainter(animation: controller, color: color, phase: phase),
        ),
      ),
    );
  }
}

class _RoundedSquarePainter extends CustomPainter {
  const _RoundedSquarePainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    canvas.drawRRect(rrect, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_RoundedSquarePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

class _Checkmark extends StatefulWidget {
  const _Checkmark({required this.reduceMotion});

  final bool reduceMotion;

  @override
  State<_Checkmark> createState() => _CheckmarkState();
}

class _CheckmarkState extends State<_Checkmark> with SingleTickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
    value: widget.reduceMotion ? 1 : 0,
  );

  @override
  void initState() {
    super.initState();
    if (!widget.reduceMotion) _pop.forward();
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: _pop, curve: CdMotion.easePop),
      child: SizedBox(
        width: 100.r,
        height: 100.r,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(100.r, 100.r),
              painter: _RoundedSquarePainter(
                color: context.getColor(ThemeEnum.inkPrimary),
                radius: 28.r,
              ),
            ),
            Icon(
              Icons.check_rounded,
              size: 50.r,
              color: context.getColor(ThemeEnum.ground),
            ),
          ],
        ),
      ),
    );
  }
}

/// One entrance block — rises 12px and fades in over 0.5s from [start].
class _Rise extends StatelessWidget {
  const _Rise({
    required this.controller,
    required this.start,
    required this.child,
    required this.reduceMotion,
  });

  final AnimationController controller;
  final double start;
  final Widget child;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    if (reduceMotion) return child;
    final anim = CurvedAnimation(
      parent: controller,
      curve: Interval(start, (start + 0.43).clamp(0.0, 1.0), curve: Curves.easeOut),
    );

    /// [FadeTransition] rather than [Opacity]: it fades at the compositor,
    /// on a layer it marks for the purpose, instead of forcing a `saveLayer`
    /// during paint. The rise stays on an `AnimatedBuilder` because the offset
    /// is 12 logical pixels, not a fraction of the child, which is the only
    /// thing `SlideTransition` can express — but [child] is passed through
    /// both, so the block itself is still built exactly once.
    return FadeTransition(
      opacity: anim,
      child: AnimatedBuilder(
        animation: anim,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, (1 - anim.value) * 12),
          child: child,
        ),
        child: child,
      ),
    );
  }
}
