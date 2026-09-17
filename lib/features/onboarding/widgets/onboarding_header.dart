import 'package:algorithm_visualizer/core/resources/logo_assets.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/skip_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({required this.onSkip, super.key});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return RSizedBox(
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const AlgoDiveMark(),
          SkipButton(onSkip: onSkip),
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
