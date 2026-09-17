import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SkipButton extends StatelessWidget {
  const SkipButton({required this.onSkip, super.key});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.topEnd,
      child: InkResponse(
        onTap: onSkip,
        radius: 44.r / 2,
        child: const RSizedBox(
          width: 44,
          height: 44,
          child:
              Center(child: MediumText(StringsManager.onboardingSkip, fontSize: 15, color: ThemeEnum.inkBody)),
        ),
      ),
    );
  }
}
