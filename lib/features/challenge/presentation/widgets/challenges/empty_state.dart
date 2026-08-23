import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChallengesEmptyState extends StatelessWidget {
  const ChallengesEmptyState({
    super.key,
    this.showIcon = true,
    this.title = StringsManager.noProblemsFound,
    this.subTitle = StringsManager.tryADifferentSearchOrFilter,
  });
  final String title;
  final String subTitle;
  final bool showIcon;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: REdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              RegularText('🔍', fontSize: 40),
              const RSizedBox(height: 12),
            ],
            SemiBoldText(title, color: ThemeEnum.textSecond, fontSize: 15),
            const RSizedBox(height: 4),
            RegularText(subTitle, color: ThemeEnum.hover, fontSize: 13),
          ],
        ),
      ),
    );
  }
}
