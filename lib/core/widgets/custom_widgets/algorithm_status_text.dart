import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/sorting/base/widgets/linear_progress_indicator.dart';
import 'package:algorithm_visualizer/lib-temp/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AlgorithmStatusText extends ConsumerWidget {
  const AlgorithmStatusText(
      {super.key, required this.statusText, required this.progressLabel, required this.progressValue});
  final String statusText;
  final String progressLabel;
  final double progressValue;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: context.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RegularText(statusText, color: ThemeEnum.white2DarkColor, fontFamily: 'JetBrainsMono', fontSize: 12),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: GradientLinearProgressIndicator(value: progressValue),
                  ),
                ),
                RSizedBox(width: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: MediumText(
                    key: ValueKey(progressLabel),
                    progressLabel,
                    fontSize: 12,
                    color: ThemeEnum.hoverColor,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
