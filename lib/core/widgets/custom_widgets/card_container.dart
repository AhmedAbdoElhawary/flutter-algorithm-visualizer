import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum CdSurface { main, secondary, unColoredFill, fill, simpleColored, outlined }

class CardContainer extends StatelessWidget {
  final Widget child;
  final CdSurface surface;
  final double radius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool clip;

  final ThemeEnum? fillColor;
  final ThemeEnum? borderColorOverride;
  final bool showBorder;
  const CardContainer({
    super.key,
    required this.child,
    this.showBorder = true,
    this.surface = CdSurface.main,
    this.radius = CdRadius.lg,
    this.padding = const EdgeInsets.all(CdSpace.gapCard),
    this.onTap,
    this.clip = false,
    this.fillColor,
    this.borderColorOverride,
  });

  ThemeEnum? get _fill =>
      fillColor ??
      switch (surface) {
        CdSurface.main => ThemeEnum.surface,
        CdSurface.secondary => ThemeEnum.raised,
        CdSurface.unColoredFill => ThemeEnum.ground,
        CdSurface.simpleColored => ThemeEnum.raised,
        CdSurface.outlined => null,
        CdSurface.fill => ThemeEnum.inkPrimary,
      };

  ThemeEnum get _borderColor =>
      borderColorOverride ??
      switch (surface) {
        CdSurface.main => ThemeEnum.raised,
        CdSurface.secondary => ThemeEnum.raised,
        CdSurface.unColoredFill => ThemeEnum.raised,
        CdSurface.simpleColored => ThemeEnum.raised,
        CdSurface.outlined => ThemeEnum.raised,
        CdSurface.fill => ThemeEnum.raised,
      };

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius.r);
    final fill = _fill;
    final box = BoxDecoration(
      color: fill == null ? null : context.getColor(fill),
      borderRadius: borderRadius,
      border: showBorder ? Border.all(color: context.getColor(_borderColor)) : null,
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
              color: context.getColor(ThemeEnum.raised),
              border: Border.all(color: context.getColor(ThemeEnum.hairline)),
            ),
            child: CustomIcon(
              icon,
              color: ThemeEnum.inkSecondaryTitle,
              size: 20,
            ),
          ),
          const Spacer(flex: 1),
          SemiBoldText(algoComplexity.name, fontSize: 14, color: ThemeEnum.inkTitle),
          const RSizedBox(height: 6),
          RSizedBox(
            height: 20,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              slivers: [
                SliverToBoxAdapter(
                  child: Row(
                    children: [
                      const CustomIcon(Icons.access_time_rounded,
                          size: 11, color: ThemeEnum.inkSecondaryTitle),
                      const RSizedBox(width: 2),
                      RegularText(algoComplexity.worstTimeComplexity.getText,
                          color: ThemeEnum.inkSecondaryTitle, fontSize: 10),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: REdgeInsetsDirectional.only(start: 5),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        const CustomIcon(Icons.storage_rounded, size: 11, color: ThemeEnum.inkSecondaryTitle),
                        const RSizedBox(width: 2),
                        RegularText(algoComplexity.spaceComplexity.getText,
                            color: ThemeEnum.inkSecondaryTitle, fontSize: 10),
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
