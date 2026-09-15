import 'package:algorithm_visualizer/features/onboarding/presentation/widgets/onboarding_text.dart';
import 'package:algorithm_visualizer/features/onboarding/presentation/widgets/onboarding_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shared body of a page: the visual card, a 34 px gap, then the copy.
///
/// Centred in the space between the header and the controls. On a short screen
/// the content scrolls instead of overflowing, which is what keeps the 360 x 640
/// case free of layout warnings.
class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    required this.visual,
    required this.headline,
    required this.body,
    super.key,
  });

  final Widget visual;
  final String headline;
  final String body;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: REdgeInsets.symmetric(horizontal: 5),
                  child: visual,
                ),
                SizedBox(height: OnboardingTokens.cardToHeadline.h),
                OnboardingCopy(headline: headline, body: body),
              ],
            ),
          ),
        );
      },
    );
  }
}
