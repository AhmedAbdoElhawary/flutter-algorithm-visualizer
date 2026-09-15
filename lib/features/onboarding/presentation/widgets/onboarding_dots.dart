import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/features/onboarding/presentation/widgets/onboarding_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Four dots. Inactive 6 x 6 in [OnboardingTokens.border], active 18 x 6 in the
/// page's own accent. Only the width animates, 180 ms.
class OnboardingDots extends StatelessWidget {
  const OnboardingDots({
    required this.count,
    required this.currentPage,
    required this.activeColor,
    super.key,
  });

  final int count;
  final int currentPage;
  final ThemeEnum activeColor;

  static const Duration _duration = Duration(milliseconds: 180);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(count, (index) {
        final isActive = index == currentPage;
        return EndPadding(
          padding: index == count - 1 ? 0 : 7,
          child: AnimatedContainer(
            duration: _duration,
            curve: Curves.easeOut,
            width: (isActive ? 18 : 6).w,
            height: 6.h,
            decoration: BoxDecoration(
              color: context.getColor(isActive ? activeColor : OnboardingTokens.border),
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
        );
      }),
    );
  }
}
