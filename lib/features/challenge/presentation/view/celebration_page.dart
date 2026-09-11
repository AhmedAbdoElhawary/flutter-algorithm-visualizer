import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/primary_button_quiet.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/secondary_button_quiet.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/stat_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Arguments for the solved-moment screen. XP / level / per-solve timing are not
/// modelled in the app yet, so only the real day streak is shown.
class CelebrationArgs {
  const CelebrationArgs({
    required this.problemName,
    required this.passedCount,
    required this.dayStreak,
  });

  final String problemName;
  final int passedCount;
  final int dayStreak;
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

class _CelebrationPageState extends State<CelebrationPage>
    with TickerProviderStateMixin {
  late final AnimationController _rings =
      AnimationController(vsync: this, duration: CdMotion.ring)..repeat();
  late final AnimationController _entrance = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1150));

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
      backgroundColor: context.getColor(ThemeEnum.primary),
      body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: REdgeInsets.fromLTRB(26, 56, 26, 120),
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
                          color: ThemeEnum.textPrimary,
                          fontSize: 25,
                          letterSpacing: -0.5,
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
                          '${args.problemName} · ${StringsManager.allNTestsPassedPrefix}${args.passedCount}${StringsManager.allNTestsPassedSuffix}',
                          color: ThemeEnum.textBody,
                          fontSize: 12.5,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ),
                    ),
                    _Rise(
                      controller: _entrance,
                      start: 0.35,
                      reduceMotion: _reduceMotion,
                      child: Padding(
                        padding: REdgeInsets.only(top: 30),
                        child: SizedBox(
                          width: 132.w,
                          child: StatTile(
                            value: '${args.dayStreak}',
                            label:
                                '${StringsManager.dayLabel} ${StringsManager.streak.toLowerCase()}',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 20.w,
                right: 20.w,
                bottom: 26.h,
                child: _Rise(
                  controller: _entrance,
                  start: 0.55,
                  reduceMotion: _reduceMotion,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PrimaryButtonQuiet(
                        label: StringsManager.nextProblem,
                        onPressed: () => context.go(Routes.practice.path),
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
    final white = context.getColor(ThemeEnum.solidWhite);
    return SizedBox(
      width: 104.r,
      height: 104.r,
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

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(size.center(Offset.zero), size.shortestSide / 2, paint);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.color != color;
}

class _Ring extends StatelessWidget {
  const _Ring(
      {required this.controller, required this.color, required this.phase});

  final AnimationController controller;
  final Color color;
  final double phase;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = (controller.value + phase) % 1.0;
        return Opacity(
          opacity: (1 - t).clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.5 + t,
            child: SizedBox(
              width: 104.r,
              height: 104.r,
              child: CustomPaint(painter: _RingPainter(color: color)),
            ),
          ),
        );
      },
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

class _CheckmarkState extends State<_Checkmark>
    with SingleTickerProviderStateMixin {
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
        width: 82.r,
        height: 82.r,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(82.r, 82.r),
              painter: _RoundedSquarePainter(
                color: context.getColor(ThemeEnum.solidWhite),
                radius: 28.r,
              ),
            ),
            Icon(
              Icons.check_rounded,
              size: 40.r,
              color: context.getColor(ThemeEnum.onPrimary),
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
      curve: Interval(start, (start + 0.43).clamp(0.0, 1.0),
          curve: Curves.easeOut),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
            offset: Offset(0, (1 - anim.value) * 12), child: child),
      ),
      child: child,
    );
  }
}
