import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Four dots. Inactive 6 x 6 in [ThemeEnum.track], active 18 x 6 in the
/// page's own accent.
///
/// [offset] is the live scroll position (2.4 means "40% of the way from page 3
/// to page 4"), so width and colour follow your finger rather than snapping
/// when the page settles.
class OnboardingDots extends StatelessWidget {
  const OnboardingDots({required this.offset, required this.accents, super.key});

  final double offset;

  /// One accent per dot, in page order.
  final List<ThemeEnum> accents;

  static const double _inactiveWidth = 6;
  static const double _activeWidth = 18;

  @override
  Widget build(BuildContext context) {
    final inactive = context.getColor(ThemeEnum.track);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(accents.length, (index) {
        // 1 when this dot is the current page, 0 once a full page away.
        final nearness = (1 - (index - offset).abs()).clamp(0.0, 1.0);

        return EndPadding(
          padding: index == accents.length - 1 ? 0 : 7,
          child: Container(
            width: (_inactiveWidth + (_activeWidth - _inactiveWidth) * nearness).w,
            height: 6.h,
            decoration: BoxDecoration(
              color: Color.lerp(inactive, context.getColor(accents[index]), nearness),
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
        );
      }),
    );
  }
}
