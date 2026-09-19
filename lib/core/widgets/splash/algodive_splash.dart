import 'dart:math' as math;

import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/material.dart';

/// AlgoDive splash. Continues the motion the native launch screen starts:
/// the native side shows the static mark on the brand ground (see
/// `assets/flutter_splash/README.md`), then this widget picks it up on the
/// first Flutter frame, finishes the mark, writes the wordmark and raises the
/// sorted bars, then calls [onFinished].
///
/// Colors and the 156x156 mark size are literal, not [ThemeEnum]/ScreenUtil
/// values: they must pixel-match the native `LaunchScreen.storyboard` /
/// Android `splash_icon.xml` exactly, or the handoff between native and
/// Flutter shows a visible seam.
class AlgoDiveSplash extends StatefulWidget {
  const AlgoDiveSplash({super.key, required this.onFinished, required this.dark});

  final VoidCallback onFinished;
  final bool dark;

  @override
  State<AlgoDiveSplash> createState() => _AlgoDiveSplashState();
}

class _AlgoDiveSplashState extends State<AlgoDiveSplash> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );

  /// Fresh heights every launch — the bars are an unsorted array, not a ramp.
  late final List<double> _heights = List<double>.generate(
    _BarsPainter.count,
    (_) => 0.22 + math.Random().nextDouble() * 0.78,
  );

  @override
  void initState() {
    super.initState();
    _c.forward().whenComplete(widget.onFinished);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _stage(double start, double end, {Curve curve = Curves.easeOutCubic}) {
    final t = ((_c.value - start) / (end - start)).clamp(0.0, 1.0);
    return curve.transform(t);
  }

  @override
  Widget build(BuildContext context) {
    /// Read from [AlgoDiveSplash.dark], never from `Theme.of`.
    ///
    /// Nothing above this widget is a `MaterialApp` — it is what `runApp`
    /// shows first — so `Theme.of` hands back Flutter's *light fallback* on
    /// every device, whatever the phone is set to. Resolving colours that way
    /// painted one fixed splash for everyone, and inverted at that: the page
    /// took `inkPrimary` and the mark took `ground`.
    ///
    /// These four values are the same ones the native launch screen uses
    /// (`android/app/src/main/res/values{,-night}/colors.xml`), so the handoff
    /// from the native screen to this one shows no colour flip.
    final background = widget.dark ? ColorManager.groundDk : ColorManager.groundLt;
    final mark = widget.dark ? ColorManager.inkPrimaryDk : ColorManager.inkPrimaryLt;
    final barOpacity = widget.dark ? 0.20 : 0.14;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: background,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final cell = _stage(0.00, 0.16, curve: Curves.easeOutBack);
            final ring1 = _stage(0.14, 0.34);
            final ring2 = _stage(0.30, 0.52);
            final route = _stage(0.50, 0.64);
            final word = _stage(0.62, 0.78);
            final bars = _stage(0.74, 1.00);

            return Stack(
              fit: StackFit.expand,
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    widthFactor: 1,
                    heightFactor: 0.18,
                    child: CustomPaint(
                      painter: _BarsPainter(
                        progress: bars,
                        color: mark.withValues(alpha: barOpacity),
                        heights: _heights,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 156,
                        height: 156,
                        child: CustomPaint(
                          painter: _MarkPainter(
                            ink: mark,
                            cell: cell,
                            ring1: ring1,
                            ring2: ring2,
                            route: route,
                          ),
                        ),
                      ),
                      const SizedBox(height: 38),

                      /// The fade rides on the text colour rather than on an
                      /// `Opacity` wrapper. `Opacity` would `saveLayer` — an
                      /// off-screen buffer and a GPU render-target switch —
                      /// once per frame, on the very first frames of a cold
                      /// start, competing with the shader warm-up. Alpha on
                      /// the colour paints the glyphs faded directly.
                      Transform.translate(
                        offset: Offset(0, 12 * (1 - word)),
                        child: Text(
                          StringsManager.algoDive,
                          style: TextStyle(
                            fontFamily: FontConstants.fontFamily,
                            color: mark.withValues(alpha: word),
                            fontSize: 54,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -1.9,
                          ),
                        ),
                      ),
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
}

class _MarkPainter extends CustomPainter {
  _MarkPainter({
    required this.ink,
    required this.cell,
    required this.ring1,
    required this.ring2,
    required this.route,
  });

  final Color ink;
  final double cell, ring1, ring2, route;

  static const _green = ColorManager.heat3;

  Path _diamond(Offset c, double r) => Path()
    ..moveTo(c.dx, c.dy - r)
    ..lineTo(c.dx + r, c.dy)
    ..lineTo(c.dx, c.dy + r)
    ..lineTo(c.dx - r, c.dy)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 512;
    canvas.save();
    canvas.scale(k);
    const c = Offset(256, 256);

    if (cell > 0) {
      final s = 0.6 + 0.4 * cell;
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.scale(s);
      canvas.translate(-c.dx, -c.dy);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(228, 228, 56, 56),
          const Radius.circular(8),
        ),
        Paint()..color = ink.withValues(alpha: cell),
      );
      canvas.restore();
    }

    void ring(double t, double radius, double width, double alpha) {
      if (t <= 0) return;
      final s = 0.5 + 0.5 * t;
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.scale(s);
      canvas.translate(-c.dx, -c.dy);
      canvas.drawPath(
        _diamond(c, radius),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeJoin = StrokeJoin.round
          ..color = ink.withValues(alpha: alpha * t),
      );
      canvas.restore();
    }

    ring(ring1, 104, 30, 1.0);
    ring(ring2, 180, 22, 0.55);

    if (route > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(398, 228, 56, 56),
          const Radius.circular(8),
        ),
        Paint()..color = _green.withValues(alpha: route),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MarkPainter old) =>
      old.cell != cell || old.ring1 != ring1 || old.ring2 != ring2 || old.route != route || old.ink != ink;
}

/// An unsorted array of bars. Each one slides up from below the bottom edge
/// into its place, left to right, 110 ms apart.
class _BarsPainter extends CustomPainter {
  _BarsPainter({
    required this.progress,
    required this.color,
    required this.heights,
  });

  final double progress;
  final Color color;

  /// Height of each bar as a fraction of the band, 0-1.
  final List<double> heights;

  static const count = 10;

  /// Share of the bars window one bar spends travelling.
  static const _travel = 0.30;

  /// Share of the window between two consecutive bars starting.
  static const _stagger = 0.075;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    const pad = 36.0;
    const gap = 9.0;
    final w = (size.width - pad * 2 - gap * (count - 1)) / count;
    final paint = Paint()..color = color;

    for (var i = 0; i < count; i++) {
      final t = ((progress - i * _stagger) / _travel).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final eased = Curves.easeOutCubic.transform(t);
      final h = size.height * heights[i];

      final top = size.height - h * eased + size.height * (1 - eased);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(pad + i * (w + gap), top, w, h),
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BarsPainter old) =>
      old.progress != progress || old.color != color || old.heights != heights;
}
