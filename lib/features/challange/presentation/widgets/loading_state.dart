import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChallengesLoadingState extends StatelessWidget {
  const ChallengesLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: REdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const RSizedBox(height: 12),
            SemiBoldText(StringsManager.loading, color: ThemeEnum.textSecond, fontSize: 15),
          ],
        ),
      ),
    );
  }
}
