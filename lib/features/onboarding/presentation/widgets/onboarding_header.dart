import 'package:algorithm_visualizer/core/resources/logo_assets.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/features/onboarding/presentation/widgets/onboarding_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Brand mark on the leading edge, Skip on the trailing edge. Fixed 44 px tall
/// and present on every page — Skip must never disappear (spec §1).
class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({required this.onSkip, super.key});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const AlgoDiveMark(),
          // 44 x 44 minimum target, so the tappable box is sized before the
          // label is centred inside it.
          InkResponse(
            onTap: onSkip,
            radius: 44.r / 2,
            child: SizedBox(
              width: 44.w,
              height: 44.h,
              child: const Center(
                child: MonoText(StringsManager.onboardingSkip, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The AlgoDive mark at header size — the two-tone brand SVG (ink + green
/// destination cell), swapped by theme brightness since it isn't tinted.
class AlgoDiveMark extends StatelessWidget {
  const AlgoDiveMark({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26.r,
      height: 26.r,
      child: SvgPicture.asset(
        context.isThemeDark ? LogoAssets.markSmallWhite : LogoAssets.markSmallBlack,
      ),
    );
  }
}
