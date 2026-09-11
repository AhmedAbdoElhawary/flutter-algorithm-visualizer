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

class AlgorithmGlassCard extends StatelessWidget {
  final AlgorithmComplexity algoComplexity;
  final IconData icon;

  const AlgorithmGlassCard({
    super.key,
    required this.algoComplexity,
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
              borderRadius: BorderRadius.circular(10.r),
              color: context.getColor(ThemeEnum.chipNeutralFill),
              border: Border.all(color: context.getColor(ThemeEnum.borderSubtle)),
            ),
            child: CustomIcon(
              icon,
              color: ThemeEnum.textBody,
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

