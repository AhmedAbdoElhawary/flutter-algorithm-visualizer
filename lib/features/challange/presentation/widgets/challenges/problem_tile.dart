import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/challange/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challange/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challange/presentation/helper/problem_style.dart';
import 'package:algorithm_visualizer/features/challange/presentation/view_model/challenges/challenges_notifier.dart';
import 'package:algorithm_visualizer/features/challange/presentation/widgets/challenges/challenge_tags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProblemTile extends ConsumerWidget {
  final CodingProblem problem;
  final VoidCallback onSolveTap;

  const ProblemTile({super.key, required this.problem, required this.onSolveTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = ref.watch(challengesProvider.select((s) => s.expandedId == problem.problemId));
    final diffColor = ProblemStyle.difficultyColor(problem.getDifficulty);
    final (statusColor, statusIcon) = ProblemStyle.getStatus(problem.problemStatus);

    return Padding(
      padding: REdgeInsets.only(bottom: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: context.getColor(ThemeEnum.card),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color:
                  expanded ? context.getColor(ThemeEnum.borderAccent) : context.getColor(ThemeEnum.border)),
          boxShadow: context.cardShadow,
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MainRow(
              problem: problem,
              expanded: expanded,
              statusColor: statusColor,
              statusIcon: statusIcon,
              diffColor: diffColor,
              onTap: () => ref.read(challengesProvider.notifier).toggleExpanded(problem.getProblemId),
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
      child: Padding(
        padding: REdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            CustomIcon(statusIcon, size: 16, color: statusColor),
            const RSizedBox(width: 8),
            SemiBoldText('${problem.number}.', color: ThemeEnum.hover, fontSize: 11),
            const RSizedBox(width: 6),
            Expanded(child: MediumText(problem.getName, color: ThemeEnum.textSecond, fontSize: 13)),
            SemiBoldText(problem.getDifficulty.difficultyString, color: diffColor, fontSize: 11),
            const RSizedBox(width: 6),
            AnimatedRotation(
              turns: expanded ? 0.25 : 0,
              duration: const Duration(milliseconds: 200),
              child: CustomIcon(Icons.chevron_right_rounded, size: 16, color: ThemeEnum.hoverSecond),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsPanel extends StatelessWidget {
  final CodingProblem problem;
  final ThemeEnum statusColor;
  final VoidCallback onSolve;

  const _DetailsPanel({required this.problem, required this.statusColor, required this.onSolve});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(border: Border(top: BorderSide(color: context.getColor(ThemeEnum.border)))),
      padding: REdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChallengeTags(tags: problem.getTags),
          const RSizedBox(height: 10),
          Row(
            children: [
              // _StatColumn(
              //     label: 'Acceptance',
              //     value: '${problem.acceptance}%',
              //     color: context.getColor(ThemeEnum.textSecond)),
              // const RSizedBox(width: 20),
              _StatColumn(
                label: StringsManager.status,
                value: problem.getProblemStatus.difficultyString,
                color: statusColor,
              ),
              const Spacer(),
              GestureDetector(
                onTap: onSolve,
                child: Container(
                  padding: REdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: context.getColor(ThemeEnum.accentBg),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: context.getColor(ThemeEnum.borderAccent)),
                  ),
                  child: SemiBoldText(StringsManager.solveWithArrow, color: ThemeEnum.accent, fontSize: 12),
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
        RegularText(label, color: ThemeEnum.hover, fontSize: 10),
        const RSizedBox(height: 2),
        SemiBoldText(value, color: color, fontSize: 13),
      ],
    );
  }
}
