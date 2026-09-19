import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/difficulty_chip.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/icon_button_quiet.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/home/view_model/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeContinueCard extends ConsumerWidget {
  const HomeContinueCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final problem = ref.watch(homeDataProvider.select((s) => s.continueProblem));

    if (problem == null) return const SizedBox.shrink();

    final quietDifficulty = problem.getDifficulty;
    final diffLabel = problem.getDifficulty.difficultyString;

    return OnlyPadding(
      startPadding: 16,
      endPadding: 16,
      bottomPadding: 14,
      child: CardContainer(
        surface: CdSurface.fill,
        padding: REdgeInsets.all(16),
        onTap: () => context.pushProblem('${problem.getProblemId}'),
        child: Row(
          children: [
            const IconButtonQuiet(
              icon: Icons.play_arrow_rounded,
              size: 48,
              iconSize: 24,
              filled: true,
              iconColor: ThemeEnum.inkPrimary,
              filledColor: ThemeEnum.ground,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MediumText(StringsManager.continueLabel,
                      fontSize: 11, maxLines: 1, color: ThemeEnum.inkSecondaryTitle),
                  SizedBox(height: 2.h),
                  BoldText(
                    problem.getName,
                    fontSize: 14,
                    color: ThemeEnum.surface,
                    maxLines: 1,
                  ),
                  const RSizedBox(height: 4),
                ],
              ),
            ),
            if (quietDifficulty != ProblemDifficulty.none)
              DifficultyChip(difficulty: quietDifficulty, label: diffLabel),
            const CustomIcon(
              Icons.chevron_right_rounded,
              color: ThemeEnum.ground,
              size: 20,
              flipsWithDirection: true,
            ),
          ],
        ),
      ),
    );
  }
}
