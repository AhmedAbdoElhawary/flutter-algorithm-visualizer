import 'package:algorithm_visualizer/core/resources/logo_assets.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
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
            child: const RSizedBox(
              width: 44,
              height: 44,
              child: Center(
                  child: MediumText(StringsManager.onboardingSkip, fontSize: 15, color: ThemeEnum.inkBody)),
            ),
          ),
        ],
      ),
    );
  }
}

class AlgoDiveMark extends StatelessWidget {
  const AlgoDiveMark({super.key});

  @override
  Widget build(BuildContext context) {
    return RSizedBox(
      width: 26,
      height: 26,
      child: SvgPicture.asset(
        context.isThemeDark ? LogoAssets.markGreenLogoWhite : LogoAssets.markGreenLogoBlack,
      ),
    );
  }
}
