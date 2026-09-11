import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The three glass depths. Depth comes from fill + blur only — no coloured
/// glows, no gradient borders. A card never sits on another card; if two glass
/// layers must overlap, the upper one steps up a depth.
enum GlassDepth { recessed, card, floating }

/// The only place in the app that composes a blur, fill, hairline, and sheen.
///
/// Takes a [depth], a [borderRadius], [padding], a [child], and an optional
/// [onTap] — never a colour argument. The drop shadow sits *outside* the clip so
/// it is not clipped away; the sheen is a 1px gradient line at the top inside
/// edge, not a second border.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final GlassDepth depth;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Duration? durationForAnimation;
  final bool allowCardTopShadow;
  final ThemeEnum fillCardTheme;
  const GlassContainer({
    super.key,
    required this.child,
    this.durationForAnimation,
    this.fillCardTheme = ThemeEnum.glassCardFill,
    this.allowCardTopShadow = true,
    this.depth = GlassDepth.card,
    this.borderRadius = CdRadius.lg,
    this.padding = const EdgeInsets.all(CdSpace.gapCard),
    this.onTap,
  });

  double get _blur => switch (depth) {
        GlassDepth.recessed => CdBlur.recessed,
        GlassDepth.card => CdBlur.card,
        GlassDepth.floating => CdBlur.floating,
      };

  double get _saturation => switch (depth) {
        GlassDepth.recessed => 1.3,
        GlassDepth.card => 1.4,
        GlassDepth.floating => 1.5,
      };

  ThemeEnum get _fill => switch (depth) {
        GlassDepth.recessed => ThemeEnum.glassRecessedFill,
        GlassDepth.card => fillCardTheme,
        GlassDepth.floating => ThemeEnum.glassFloatingFill,
      };

  ThemeEnum get _hairline => switch (depth) {
        GlassDepth.recessed => ThemeEnum.glassHairlineRecessed,
        GlassDepth.card => ThemeEnum.border,
        GlassDepth.floating => ThemeEnum.borderStrong,
      };

  List<BoxShadow> _shadow(BuildContext context) => switch (depth) {
        GlassDepth.recessed => const [],
        GlassDepth.card => context.isThemeDark ? CdElevation.e2 : context.cardShadow,
        GlassDepth.floating => context.isThemeDark ? CdElevation.e3 : context.cardShadow,
      };

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius.r);
    final borderSide = BorderSide(color: context.getColor(_hairline));
    final box = BoxDecoration(
      color: context.getColor(_fill),
      borderRadius: radius,
      border: Border(
        bottom: borderSide,
        left: borderSide,
        right: borderSide,
        top: BorderSide(
            color: context.getColor(_hairline),
            width: !allowCardTopShadow && depth != GlassDepth.recessed ? 2 : 1),
      ),
    );
    final surface = durationForAnimation != null
        ? AnimatedContainer(
            duration: durationForAnimation!,
            decoration: box,
            child: child,
          )
        : Container(
            padding: padding,
            decoration: box,
            child: child,
          );

    // Shadow sits outside the clip.
    final result = DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: _shadow(context)),
      child: surface,
    );

    if (onTap == null) return result;
    return GestureDetector(onTap: onTap, child: result);
  }
}

/// The recessed-track variant — progress-bar fills, segmented-control and
/// chip-row backgrounds. The reference draws these rails at white 10–13%
/// ([ThemeEnum.primaryTint]), not the 4% recessed-glass fill, and a blurred
/// sub-surface inside a glass card is a needless [BackdropFilter] nest, so this
/// is a plain clipped fill with no blur, sheen, or shadow.
class GlassTrack extends StatelessWidget {
  final Widget child;
  final double? height;
  final double borderRadius;

  const GlassTrack({
    super.key,
    required this.child,
    this.height,
    this.borderRadius = CdRadius.pill,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius.r),
      child: Container(
        height: height?.r,
        color: context.getColor(ThemeEnum.primaryTint),
        child: child,
      ),
    );
  }
}

/// The ground. Paints, bottom to top: the base colour, a radial indigo band
/// rising from the bottom edge, a smaller cyan band, then a dot grid, then the
/// child. Static by default — pass [animate] only on Home, and it still yields
/// to the OS "reduce motion" setting.
class AuroraGround extends StatelessWidget {
  final Widget? child;

  const AuroraGround({super.key, this.child});

  @override
  Widget build(BuildContext context) {

    return Stack(
      fit: StackFit.expand,
      children: [
        // Positioned.fill(
        //   child: CustomPaint(
        //     size: Size.infinite,
        //     painter: _AuroraPainter(
        //       base: context.getColor(ThemeEnum.primary),
        //       indigo: context.getColor(ThemeEnum.glowIndigo),
        //       cyan: context.getColor(ThemeEnum.glowCyan),
        //       dot: context.getColor(ThemeEnum.dotGrid),
        //       dotSpacing: 13.r,
        //     ),
        //   ),
        // ),
        if (child != null) child!,
      ],
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final Color base;
  final Color indigo;
  final Color cyan;
  final Color dot;
  final double dotSpacing;

  const _AuroraPainter({
    required this.base,
    required this.indigo,
    required this.cyan,
    required this.dot,
    required this.dotSpacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final full = Offset.zero & size;
    canvas.drawRect(full, Paint()..color = base);

    _band(canvas, full, indigo,
        center: Offset(size.width * 0.5, size.height * 1.12), radius: size.width * 0.66);
    _band(canvas, full, cyan,
        center: Offset(size.width * 0.82, size.height * 1.06), radius: size.width * 0.42);

    // final dotPaint = Paint()..color = dot;
    // for (double y = 0; y <= size.height; y += dotSpacing) {
    //   for (double x = 0; x <= size.width; x += dotSpacing) {
    //     canvas.drawCircle(Offset(x, y), 0.9, dotPaint);
    //   }
    // }
  }

  void _band(Canvas canvas, Rect area, Color color, {required Offset center, required double radius}) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawRect(
      area,
      Paint()
        ..shader = RadialGradient(colors: [color, color.withValues(alpha: 0)]).createShader(rect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, CdBlur.groundMask),
    );
  }

  @override
  bool shouldRepaint(_AuroraPainter old) =>
      old.base != base ||
      old.indigo != indigo ||
      old.cyan != cyan ||
      old.dot != dot ||
      old.dotSpacing != dotSpacing;
}

class AlgorithmGlassCard extends StatelessWidget {
  final AlgorithmComplexity algoComplexity;
  final Color color;
  final IconData icon;

  const AlgorithmGlassCard({
    super.key,
    required this.algoComplexity,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: CdRadius.xl,
      padding: REdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30.r,
            height: 30.r,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: color.withValues(alpha: .14),
              border: Border.all(
                color: color.withValues(alpha: .24),
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const Spacer(flex: 1),
          SemiBoldText(algoComplexity.name, fontSize: 14, color: ThemeEnum.textPrimary),
          const SizedBox(height: 6),
          RSizedBox(
            height: 20,
            child: CustomScrollView(
              scrollDirection: Axis.horizontal,
              slivers: [
                SliverToBoxAdapter(
                  child: Row(
                    children: [
                      const CustomIcon(Icons.access_time_rounded, size: 11, color: ThemeEnum.text2DarkColor),
                      const RSizedBox(width: 2),
                      RegularText(algoComplexity.worstTimeComplexity.getText,
                          color: ThemeEnum.textDarkColor, fontSize: 10),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: REdgeInsetsDirectional.only(start: 5),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        const CustomIcon(Icons.storage_rounded, size: 11, color: ThemeEnum.text2DarkColor),
                        const RSizedBox(width: 2),
                        RegularText(algoComplexity.spaceComplexity.getText,
                            color: ThemeEnum.textDarkColor, fontSize: 10),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}

class SimpleControllerGlassButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String? messageTip;
  final Widget child;
  final GlassDepth depth;
  final EdgeInsetsGeometry padding;
  const SimpleControllerGlassButton({
    super.key,
    required this.child,
    this.depth = GlassDepth.card,
    this.padding = const EdgeInsets.all(10),
    this.onTap,
    this.messageTip,
  });

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        depth: depth,
        borderRadius: 12,
        padding: padding,
        child: child,
      ),
    );
    return messageTip != null ? Tooltip(message: messageTip!, child: button) : button;
  }
}

/// Deprecated alias — the old three-orb backdrop is gone. Kept so its remaining
/// call sites keep compiling until they move to [AuroraGround] directly.
class AnimatedBackground extends StatelessWidget {
  const AnimatedBackground({super.key});

  @override
  Widget build(BuildContext context) => const AuroraGround();
}
