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

    if (onTap == null) return surface;
    return GestureDetector(onTap: onTap, child: surface);
  }
}

/// The recessed-track variant — progress-bar fills, segmented-control and
/// chip-row backgrounds. The reference draws these rails at white 10–13%
/// ([ThemeEnum.primaryTint]), not the 4% recessed-glass fill: a plain clipped
/// fill with no blur, sheen, or shadow.
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
        if (child != null) child!,
      ],
    );
  }
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
