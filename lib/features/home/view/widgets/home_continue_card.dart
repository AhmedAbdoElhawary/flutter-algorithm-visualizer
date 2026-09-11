import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/glass_card.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/helper/problem_style.dart';
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

    final diffColor = ProblemStyle.difficultyColor(problem.getDifficulty);
    final diffLabel = problem.getDifficulty.difficultyString;

    return OnlyPadding(
      startPadding: 16,
      endPadding: 16,
      bottomPadding: 14,
      child: GlassContainer(
        depth: GlassDepth.card,
        borderRadius: 20,
        padding: REdgeInsets.all(16),
        onTap: () => context.pushTo(Routes.problem, queryParameters: '${problem.getProblemId}'),
        child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: context.getColor(ThemeEnum.accentXp),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(Icons.play_arrow_rounded, color: context.getColor(ThemeEnum.onPrimary), size: 24.r),
              ),
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
              if (diffLabel.isNotEmpty)
                Container(
                  padding: REdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.getColor(diffColor).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: RegularText(diffLabel, fontSize: 10, color: diffColor),
                ),
              Icon(Icons.chevron_right_rounded, color: context.getColor(ThemeEnum.textSecond), size: 20.r),
            ],
          ),
      ),
    );
  }
}
