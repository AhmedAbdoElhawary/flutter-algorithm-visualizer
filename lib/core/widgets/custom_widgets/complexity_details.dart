import 'package:algorithm_visualizer/core/helpers/o_notation.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ComplexityDetails extends StatelessWidget {
  const ComplexityDetails({super.key, required this.complexity});

  final AlgorithmComplexity complexity;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          RSizedBox(width: 16),
          TimeComplexityData(complexity: complexity),
          RSizedBox(width: 10),
          SpaceComplexityData(complexity: complexity),
          RSizedBox(width: 16),
        ],
      ),
    );
  }
}

class TimeComplexityData extends StatelessWidget {
  const TimeComplexityData({super.key, required this.complexity});

  final AlgorithmComplexity complexity;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      withAboveShadow: false,
      borderRadius: 8,
      padding: REdgeInsets.all(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIcon(Icons.access_time_rounded, size: 14, color: ThemeEnum.hoverColor),
          RSizedBox(width: 4),
          RegularText(StringsManager.time, color: ThemeEnum.hoverColor, fontSize: 14),
          RSizedBox(width: 2),
          RegularText(StringsManager.best, color: ThemeEnum.white2DarkColor, fontSize: 12),
          RSizedBox(width: 2),
          SemiBoldText(complexity.bestTimeComplexity.getText, color: ThemeEnum.greenColor, fontSize: 14),
          RSizedBox(width: 4),
          RegularText(StringsManager.worst, color: ThemeEnum.white2DarkColor, fontSize: 12),
          RSizedBox(width: 2),
          SemiBoldText(complexity.worstTimeComplexity.getText, color: ThemeEnum.mainDarkColor, fontSize: 14),
        ],
      ),
    );
  }
}


class SpaceComplexityData extends StatelessWidget {
  const SpaceComplexityData({super.key, required this.complexity});

  final AlgorithmComplexity complexity;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      withAboveShadow: false,
      borderRadius: 8,
      padding: REdgeInsets.all(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIcon(Icons.storage_rounded, size: 14, color: ThemeEnum.hoverColor),
          RSizedBox(width: 4),
          RegularText(StringsManager.space, color: ThemeEnum.hoverColor, fontSize: 14),
          RSizedBox(width: 2),
          SemiBoldText(complexity.spaceComplexity.getText, color: ThemeEnum.mainDarkColor, fontSize: 14),
        ],
      ),
    );
  }
}
