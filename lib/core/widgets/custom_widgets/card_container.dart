import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum CdSurface { main, secondary, recessed, outline }

class CardContainer extends StatelessWidget {
  final Widget child;
  final CdSurface surface;
  final double radius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool clip;

  const CardContainer({
    super.key,
    required this.child,
    this.surface = CdSurface.main,
    this.radius = CdRadius.lg,
    this.padding = const EdgeInsets.all(CdSpace.gapCard),
    this.onTap,
    this.clip = false,
  });

  ThemeEnum? get _fill => switch (surface) {
        CdSurface.main => ThemeEnum.mainCard,
        CdSurface.secondary => ThemeEnum.surfaceRaised,
        CdSurface.recessed => ThemeEnum.bgBase,
        CdSurface.outline => null,
      };

  ThemeEnum get _borderColor => switch (surface) {
        CdSurface.main => ThemeEnum.borderSubtle,
        CdSurface.secondary => ThemeEnum.border,
        CdSurface.recessed => ThemeEnum.borderSubtle,
        CdSurface.outline => ThemeEnum.borderSubtle,
      };

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius.r);
    final fill = _fill;
    final box = BoxDecoration(
      color: fill == null ? null : context.getColor(fill),
      borderRadius: borderRadius,
      border: Border.all(color: context.getColor(_borderColor)),
    );
    Widget surfaceWidget = Container(
      padding: padding,
      decoration: box,
      child: child,
    );

    if (clip) {
      surfaceWidget = ClipRRect(borderRadius: borderRadius, child: surfaceWidget);
    }

    if (onTap == null) return surfaceWidget;
    return GestureDetector(onTap: onTap, child: surfaceWidget);
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
    return CardContainer(
      radius: CdRadius.xl,
      padding: REdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30.r,
            height: 30.r,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(CdRadius.smAlt.r),
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
            child: CustomScrollView(      physics: const BouncingScrollPhysics(),

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
