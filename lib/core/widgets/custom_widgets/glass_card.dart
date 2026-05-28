import 'dart:ui';
import 'package:algorithm_visualizer/core/helpers/o_notation.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GlassCard extends StatelessWidget {
  final AlgorithmComplexity algoComplexity;
  final Color color;
  final IconData icon;

  const GlassCard({
    super.key,
    required this.algoComplexity,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      color: ThemeEnum.cardGlassColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: color.withValues(alpha: .14),
              border: Border.all(
                color: color.withValues(alpha: .24),
              ),
            ),
            child: Icon(icon, color: color),
          ),
          const Spacer(flex: 6),
          SemiBoldText(algoComplexity.name),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CustomIcon(Icons.access_time_rounded, size: 12, color: ThemeEnum.text2DarkColor),
                  RSizedBox(width: 2),
                  RegularText(algoComplexity.worstTimeComplexity.getText,
                      color: ThemeEnum.textDarkColor, fontSize: 11),
                ],
              ),
              Spacer(),
              Row(
                children: [
                  CustomIcon(Icons.storage_rounded, size: 12, color: ThemeEnum.text2DarkColor),
                  RSizedBox(width: 2),
                  RegularText(algoComplexity.spaceComplexity.getText,
                      color: ThemeEnum.textDarkColor, fontSize: 11),
                ],
              ),
              Spacer(),
            ],
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final bool withAboveShadow;
  final bool highlightCard;
  final ThemeEnum color;
  const GlassContainer({
    super.key,
    required this.child,
    this.color = ThemeEnum.glassColor,
    this.borderRadius = 20,
    this.borderWidth = 0.5,
    this.withAboveShadow = true,
    this.highlightCard = false,
    this.padding = const EdgeInsets.all(15),
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = context.getColor(highlightCard ? ThemeEnum.borderPurpleColor : ThemeEnum.shadowColor);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: context.getColor(highlightCard ? ThemeEnum.lightPurpleColor : color),
            border: Border(
              top: BorderSide(
                  color: borderColor,
                  width: withAboveShadow ? 1.5 : borderWidth,
                  strokeAlign: withAboveShadow ? -2 : -1),
              right: BorderSide(color: borderColor, width: borderWidth),
              left: BorderSide(color: borderColor, width: borderWidth),
              bottom: BorderSide(color: borderColor, width:borderWidth),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class AnimatedBackground extends StatelessWidget {
  const AnimatedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -80,
          child: _ORB(
            color: const Color(0xFF5B9CF6),
            size: 260,
          ),
        ),
        Positioned(
          top: 220,
          right: -100,
          child: _ORB(
            color: const Color(0xFFA78BFA),
            size: 280,
          ),
        ),
        Positioned(
          bottom: -120,
          left: -60,
          child: _ORB(
            color: const Color(0xFF38BDF8),
            size: 240,
          ),
        ),
      ],
    );
  }
}

class _ORB extends StatelessWidget {
  const _ORB({required this.size, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
