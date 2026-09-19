import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ComplexityDetails extends StatelessWidget {
  const ComplexityDetails({super.key, required this.complexity});

  final AlgorithmComplexity complexity;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 10,
          children: [
            TimeComplexityData(complexity: complexity),
            SpaceComplexityData(complexity: complexity),
            StabilityData(complexity: complexity),
          ],
        ),
      ),
    );
  }
}

class TimeComplexityData extends StatelessWidget {
  const TimeComplexityData({super.key, required this.complexity});

  final AlgorithmComplexity complexity;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      surface: CdSurface.unColoredFill,
      radius: CdRadius.xs,
      padding: REdgeInsets.all(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomIcon(Icons.access_time_rounded, size: 14, color: ThemeEnum.inkThirdTitle),
          const RSizedBox(width: 4),
          const RegularText(StringsManager.time, color: ThemeEnum.inkThirdTitle, fontSize: 14),
          const RSizedBox(width: 2),
          SemiBoldText(complexity.worstTimeComplexity.getText,
              color: ThemeEnum.inkSecondaryTitle, fontSize: 14),
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
    return CardContainer(
      surface: CdSurface.unColoredFill,
      radius: CdRadius.xs,
      padding: REdgeInsets.all(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomIcon(Icons.storage_rounded, size: 14, color: ThemeEnum.inkThirdTitle),
          const RSizedBox(width: 4),
          const RegularText(StringsManager.space, color: ThemeEnum.inkThirdTitle, fontSize: 14),
          const RSizedBox(width: 2),
          SemiBoldText(complexity.spaceComplexity.getText, color: ThemeEnum.inkSecondaryTitle, fontSize: 14),
        ],
      ),
    );
  }
}

class StabilityData extends StatelessWidget {
  const StabilityData({super.key, required this.complexity});

  final AlgorithmComplexity complexity;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      surface: CdSurface.unColoredFill,
      radius: CdRadius.xs,
      padding: REdgeInsets.all(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomIcon(Icons.balance_rounded, size: 14, color: ThemeEnum.inkThirdTitle),
          const RSizedBox(width: 4),
          const RegularText(StringsManager.stable, color: ThemeEnum.inkThirdTitle, fontSize: 14),
          const RSizedBox(width: 2),
          SemiBoldText(complexity.getStabilityText, color: ThemeEnum.dataEasy, fontSize: 14),
        ],
      ),
    );
  }
}
