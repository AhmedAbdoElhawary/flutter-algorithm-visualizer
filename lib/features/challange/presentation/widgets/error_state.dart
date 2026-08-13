import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChallengesErrorState extends StatelessWidget {
  const ChallengesErrorState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child:Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIcon(Icons.error_outline_rounded, size: 60, color: ThemeEnum.accent),
          const RSizedBox(height: 12),
          SemiBoldText(StringsManager.errorText, color: ThemeEnum.textSecond, fontSize: 15),
          const RSizedBox(height: 4),
          RegularText(StringsManager.tryInDifferentTime, color: ThemeEnum.hover, fontSize: 13),
        ],
      ),
    );
  }
}