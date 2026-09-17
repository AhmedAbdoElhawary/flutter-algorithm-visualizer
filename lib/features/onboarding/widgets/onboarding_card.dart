import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/features/onboarding/widgets/onboarding_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Surface fill, 1 px hairline, radius 14 — the frame every visual sits in.
class OnboardingCard extends StatelessWidget {
  const OnboardingCard({required this.child, this.clip = false, super.key});

  final Widget child;

  /// The editor card draws its own internal dividers edge to edge, so it
  /// clips instead of padding.
  final bool clip;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.getColor(ThemeEnum.raised),
        border: Border.all(color: context.getColor(ThemeEnum.hairline)),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: clip
          ? ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: child,
            )
          : child,
    );
  }
}

/// One `● Label` pair in a legend row.
class LegendItem extends StatelessWidget {
  const LegendItem({required this.color, required this.label, super.key});

  final ThemeEnum color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.r,
          height: 8.r,
          decoration: BoxDecoration(
            color: context.getColor(color),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6.w),
        MonoText(label),
      ],
    );
  }
}

/// Mono 12 legend under a visual. Wraps rather than overflowing on narrow
/// screens.
class OnboardingLegend extends StatelessWidget {
  const OnboardingLegend({required this.items, super.key});

  final List<LegendItem> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14.r,
      runSpacing: 6.r,
      alignment: WrapAlignment.center,
      children: items,
    );
  }
}

/// The hairline-topped caption strip at the bottom of a visual card.
class OnboardingCaptionBar extends StatelessWidget {
  const OnboardingCaptionBar({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.only(top: 4),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: context.getColor(ThemeEnum.hairline)),
        ),
      ),
      child: child,
    );
  }
}
