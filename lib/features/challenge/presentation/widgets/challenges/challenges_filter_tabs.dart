import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/helper/problem_style.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/challenges_notifier.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/challenges_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChallengesFilterTabs extends ConsumerWidget {
  const ChallengesFilterTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(challengesProvider.select((s) => s.filter));

    return Padding(
      padding: REdgeInsets.fromLTRB(16, 0, 16, 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ChallengesNotifier.filters.map((f) {
            final active = activeFilter == f;
            final color = f == ProblemDifficulty.none ? ThemeEnum.accent : ProblemStyle.difficultyColor(f);
            final count = ref
                .watch(specificDifficultyCountProvider(f))
                .maybeWhen(data: (data) => "$data", orElse: () => "");

            return GestureDetector(
              onTap: () => ref.read(challengesProvider.notifier).setFilter(f),
              child: Container(
                margin: REdgeInsetsDirectional.only(end: 8),
                padding: REdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: active
                      ? context.getColor(color).withValues(alpha: 0.10)
                      : context.getColor(ThemeEnum.card),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: active
                          ? context.getColor(color).withValues(alpha: 0.35)
                          : context.getColor(ThemeEnum.border)),
                  boxShadow: context.cardShadow,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BoldText(f.difficultyString, color: active ? color : ThemeEnum.hover, fontSize: 13),
                    const SizedBox(width: 5),
                    SemiBoldText(count, color: active ? color : ThemeEnum.hoverSecond, fontSize: 11),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
