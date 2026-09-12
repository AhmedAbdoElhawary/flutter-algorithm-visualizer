import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/helper/problem_style.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/bookmark_button.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/challenge_tags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProblemTile extends ConsumerWidget {
  final int problemId;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onSolveTap;

  const ProblemTile({
    super.key,
    required this.problemId,
    required this.expanded,
    required this.onToggle,
    required this.onSolveTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final problem = ref.watch(getProblemProvider(problemId).select((async) => async.value));
    if (problem == null) return const SizedBox.shrink();

    final diffColor = ProblemStyle.difficultyColor(problem.getDifficulty);
    final (statusColor, statusIcon) = ProblemStyle.getStatus(problem.problemStatus);

    return OnlyPadding(
      bottomPadding: 6,
      child: Stack(
        children: [
          CardContainer(
            surface: CdSurface.main,
            radius: CdRadius.medium,
            padding: EdgeInsets.zero,
            clip: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MainRow(
                  problem: problem,
                  expanded: expanded,
                  statusColor: statusColor,
                  statusIcon: statusIcon,
                  diffColor: diffColor,
                  onTap: onToggle,
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  child: expanded
                      ? _DetailsPanel(problem: problem, statusColor: statusColor, onSolve: onSolveTap)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(CdRadius.medium.r),
                  border: Border.all(
                    color: context.getColor(expanded ? ThemeEnum.borderAccent : ThemeEnum.borderSubtle),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MainRow extends StatelessWidget {
  final CodingProblem problem;
  final bool expanded;
  final ThemeEnum statusColor;
  final ThemeEnum diffColor;
  final IconData statusIcon;
  final VoidCallback onTap;

  const _MainRow({
    required this.problem,
    required this.expanded,
    required this.statusColor,
    required this.diffColor,
    required this.statusIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SymmetricPadding(
        horizontal: 14,
        vertical: 11,
        child: Row(
          children: [
            CustomIcon(statusIcon, size: 16, color: statusColor),
            const RSizedBox(width: 6),
            BoldText('${problem.number}.', color: ThemeEnum.textBody, fontSize: 11),
            const RSizedBox(width: 6),
            Expanded(child: BoldText(problem.getName, color: ThemeEnum.textBody, fontSize: 13)),
            const RSizedBox(width: 4),

            BoldText(problem.getDifficulty.difficultyString, color: diffColor, fontSize: 11),
            const RSizedBox(width: 4),
            AnimatedRotation(
              turns: expanded ? 0.25 : 0,
              duration: const Duration(milliseconds: 200),
              child: const CustomIcon(Icons.chevron_right_rounded, size: 16, color: ThemeEnum.hover),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsPanel extends ConsumerWidget {
  final CodingProblem problem;
  final ThemeEnum statusColor;
  final VoidCallback onSolve;

  const _DetailsPanel({required this.problem, required this.statusColor, required this.onSolve});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarked = problem.getIsBookmarked;

    return Container(
      width: double.infinity,
      decoration:
          BoxDecoration(border: Border(top: BorderSide(color: context.getColor(ThemeEnum.borderSubtle)))),
      padding: REdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChallengeTags(tags: problem.getTags),
          const RSizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 36,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    _StatColumn(
                      label: StringsManager.status,
                      value: problem.getProblemStatus.difficultyString,
                      color: statusColor,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const OnlyPadding(
                          startPadding: 3,
                          child:
                              MediumText(StringsManager.bookmarked, color: ThemeEnum.textBody, fontSize: 10),
                        ),
                        const RSizedBox(height: 2),
                        BookmarkButton(isBookmarked: isBookmarked, problem: problem),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onSolve,
                child: Container(
                  padding: REdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: context.getColor(ThemeEnum.accentBg),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: context.getColor(ThemeEnum.borderAccent)),
                  ),
                  child: const BoldText(StringsManager.solveWithArrow, color: ThemeEnum.accent, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final ThemeEnum color;

  const _StatColumn({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MediumText(label, color: ThemeEnum.textBody, fontSize: 10),
        const RSizedBox(height: 2),
        SemiBoldText(value, color: color, fontSize: 13),
      ],
    );
  }
}
