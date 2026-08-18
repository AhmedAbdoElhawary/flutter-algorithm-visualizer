import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/challange/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challange/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/home/view_model/home_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeContinueCard extends ConsumerWidget {
  const HomeContinueCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final problem = ref.watch(homeDataProvider.select((s) => s.continueProblem));

    if (problem == null) return const SizedBox.shrink();

    final diff = problem.getDifficulty;
    final diffLabel = switch (diff) {
      ProblemDifficulty.easy => 'Easy',
      ProblemDifficulty.medium => 'Medium',
      ProblemDifficulty.hard => 'Hard',
      _ => '',
    };
    final diffColor = switch (diff) {
      ProblemDifficulty.easy => ThemeEnum.accentGreen,
      ProblemDifficulty.medium => ThemeEnum.accentYellow,
      ProblemDifficulty.hard => ThemeEnum.accentRed,
      _ => ThemeEnum.accent,
    };

    return OnlyPadding(
      startPadding: 16,
      endPadding: 16,
      bottomPadding: 14,
      child: GestureDetector(
        onTap: () => context.pushTo(Routes.code, queryParameters: '${problem.getProblemId}'),
        child: Container(
          padding: REdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.getColor(ThemeEnum.accentBg),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: context.getColor(ThemeEnum.borderAccent)),
            boxShadow: context.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: context.getColor(ThemeEnum.accent).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: context.getColor(ThemeEnum.borderAccent)),
                ),
                child: Icon(Icons.play_arrow_rounded, color: context.getColor(ThemeEnum.accent), size: 24.r),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RegularText('CONTINUE LEARNING', fontSize: 11, color: ThemeEnum.textSecond),
                    SizedBox(height: 2.h),
                    BoldText(
                      problem.getName,
                      fontSize: 14,
                      color: ThemeEnum.textPrimary,
                      maxLines: 1,
                    ),
                    SizedBox(height: 4.h),
                    if (diffLabel.isNotEmpty)
                      Container(
                        padding: REdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.getColor(diffColor).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: RegularText(diffLabel, fontSize: 10, color: diffColor),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: context.getColor(ThemeEnum.textSecond), size: 20.r),
            ],
          ),
        ),
      ),
    );
  }
}
