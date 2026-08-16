import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChallengeTags extends StatelessWidget {
  const ChallengeTags({super.key, required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: tags
          .map(
            (t) => Container(
              padding: REdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: context.getColor(ThemeEnum.accentBg),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: context.getColor(ThemeEnum.borderAccent)),
              ),
              child: RegularText(t, color: ThemeEnum.accent, fontSize: 11),
            ),
          )
          .toList(),
    );
  }
}
