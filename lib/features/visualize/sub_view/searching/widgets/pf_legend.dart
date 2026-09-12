import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/searching/widgets/end_point.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/searching/widgets/start_point.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PFLegend extends StatelessWidget {
  const PFLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (ThemeEnum.difficultyEasy, StringsManager.start),
      (ThemeEnum.difficultyEasy, StringsManager.end),
      (ThemeEnum.borderStrong, StringsManager.wall),
      (ThemeEnum.barIdle, StringsManager.visited),
      (ThemeEnum.comparing, StringsManager.frontier),
      (ThemeEnum.difficultyEasy, StringsManager.path),
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Wrap(
          spacing: 12,
          runSpacing: 4,
          children: items.map((item) {
            final (role, label) = item;
            return Row(mainAxisSize: MainAxisSize.min, children: [
              if (label == StringsManager.start)
                PFStartPointWidget(size: 10.r, color: context.getColor(ThemeEnum.textBright))
              else if (label == StringsManager.end)
                PFEndPointWidget(
                  size: 12.r,
                  outerColor: context.getColor(ThemeEnum.difficultyEasy),
                  midColor: context.getColor(ThemeEnum.textBright),
                  innerColor: context.getColor(ThemeEnum.difficultyEasy),
                )
              else
                Icon(Icons.circle, size: 10.r, color: context.getColor(role)),
              const RSizedBox(width: 4),
              RegularText(label, color: ThemeEnum.textSecond, fontSize: 10),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
