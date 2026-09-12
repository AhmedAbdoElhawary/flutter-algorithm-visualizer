import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/difficulty_chip.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/icon_button_quiet.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/live_session_card.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/home/view_model/home_provider.dart';
import 'package:algorithm_visualizer/features/visualize/view_model/live_session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeContinueCard extends ConsumerWidget {
  const HomeContinueCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLive = ref.watch(liveSessionProvider.select((s) => s != null));
    if (isLive) {
      return const OnlyPadding(
        startPadding: 16,
        endPadding: 16,
        bottomPadding: 14,
        child: LiveSessionCard(),
      );
    }

    final problem = ref.watch(homeDataProvider.select((s) => s.continueProblem));

    if (problem == null) return const SizedBox.shrink();

    final quietDifficulty =problem.getDifficulty;
    final diffLabel = problem.getDifficulty.difficultyString;

    return OnlyPadding(
      startPadding: 16,
      endPadding: 16,
      bottomPadding: 14,
      child: CardContainer(
        surface: CdSurface.main,
        padding: REdgeInsets.all(16),
        onTap: () => context.pushTo(Routes.problem, queryParameters: '${problem.getProblemId}'),
        child: Row(
            children: [
              const IconButtonQuiet(icon: Icons.play_arrow_rounded, size: 48, iconSize: 24, filled: true),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const RegularText(StringsManager.continueLabel, fontSize: 11,maxLines: 1, color: ThemeEnum.textSecond),
                    SizedBox(height: 2.h),
                    BoldText(
                      problem.getName,
                      fontSize: 14,
                      color: ThemeEnum.textPrimary,
                      maxLines: 1,
                    ),
                    SizedBox(height: 4.h),


                  ],
                ),
              ),
              if (quietDifficulty != ProblemDifficulty.none) DifficultyChip(difficulty: quietDifficulty, label: diffLabel),
              Icon(Icons.chevron_right_rounded, color: context.getColor(ThemeEnum.textSecond), size: 20.r),
            ],
          ),
      ),
    );
  }
}
