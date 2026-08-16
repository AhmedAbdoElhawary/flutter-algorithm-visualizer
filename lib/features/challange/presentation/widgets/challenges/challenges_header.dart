import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/challange/presentation/view_model/challenges/challenges_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChallengesHeader extends ConsumerWidget {
  const ChallengesHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total =
        ref.watch(filteredProblemsProvider).maybeWhen(data: (data) => data.length, orElse: () => -1);
    final totalText = total == -1 ? StringsManager.nan : "$total";

    final solved = ref.watch(solvedCountProvider).maybeWhen(data: (data) => data, orElse: () => -1);
    final solvedText = solved == -1 ? StringsManager.nan : "$solved";

    final isLoaded = solved != -1 && total != -1;
    return Padding(
      padding: REdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MediumText(
            StringsManager.practice.toUpperCase(),
            color: ThemeEnum.hover,
            letterSpacing: 0.5,
            fontSize: 12,
          ),
          const RSizedBox(height: 2),
          Row(
            children: [
              BoldText(
                StringsManager.challenges,
                color: ThemeEnum.textPrimary,
                letterSpacing: -0.4,
                fontSize: 20,
              ),
              const Spacer(),
              if (isLoaded) ...[
                CustomIcon(Icons.local_fire_department_rounded, size: 14, color: ThemeEnum.accentRed),
                const RSizedBox(width: 3),
                SemiBoldText(solvedText, color: ThemeEnum.accentBg, fontSize: 13),
                SemiBoldText(' / ', color: ThemeEnum.accentBg, fontSize: 13),
                RegularText(totalText, color: ThemeEnum.hover, fontSize: 13),
                RSizedBox(width: 2),
                RegularText(StringsManager.solved, color: ThemeEnum.hover, fontSize: 13),
              ],
            ],
          ),
          const RSizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: total == 0 || !isLoaded ? 0 : solved / total),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOut,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 4.r,
                backgroundColor: context.getColor(ThemeEnum.outputHeader),
                valueColor: AlwaysStoppedAnimation(context.getColor(ThemeEnum.accentGreen)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
