import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/problem_row.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/secondary_button_quiet.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/helper/problem_style.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/challenges_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/bookmark_button.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/challenge_tags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProblemTile extends ConsumerWidget {
  final int problemId;
  final VoidCallback onSolveTap;

  const ProblemTile({super.key, required this.problemId, required this.onSolveTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final problem = ref.watch(getProblemProvider(problemId).select((async) => async.value));
    if (problem == null) return const SizedBox.shrink();

    final expanded = ref.watch(challengesProvider.select((s) => s.expandedId == problemId));
    final diffColor = ProblemStyle.difficultyColor(problem.getDifficulty);
    final (statusColor, statusIcon) = ProblemStyle.getStatus(problem.problemStatus);

    return Padding(
      padding: REdgeInsets.only(bottom: 6),
      child: ProblemRow(
        selected: expanded,
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
      // behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: REdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            CustomIcon(statusIcon, size: 16, color: statusColor),
            const RSizedBox(width: 6),
            BoldText('${problem.number}.', color: ThemeEnum.hover, fontSize: 11),
            const RSizedBox(width: 6),
            Expanded(child: BoldText(problem.getName, color: ThemeEnum.white2DarkColor, fontSize: 13)),
            const RSizedBox(width: 4),

            BoldText(problem.getDifficulty.difficultyString, color: diffColor, fontSize: 11),
            const RSizedBox(width: 4),
            AnimatedRotation(
              turns: expanded ? 0.25 : 0,
              duration: const Duration(milliseconds: 200),
              child: const CustomIcon(Icons.chevron_right_rounded, size: 16, color: ThemeEnum.white2DarkColor),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 1, color: context.getColor(ThemeEnum.border)),
        Padding(
          padding: REdgeInsets.fromLTRB(14, 10, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChallengeTags(tags: problem.getTags),
              const RSizedBox(height: 10),
          Row(
            children: [
              _StatColumn(
                label: StringsManager.status,
                value: problem.getProblemStatus.difficultyString,
                color: statusColor,
              ),
              const RSizedBox(width: 36),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const OnlyPadding(
                    startPadding: 3,
                    child: MediumText(StringsManager.bookmarked, color: ThemeEnum.hover, fontSize: 10),
                  ),
                  const RSizedBox(height: 2),
                  BookmarkButton(isBookmarked: isBookmarked, problem: problem),
                ],
              ),
              const Spacer(),
              SecondaryButtonQuiet(label: StringsManager.solveWithArrow, onPressed: onSolve, expand: false),
            ],
          ),
            ],
          ),
        ),
      ],
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
        MediumText(label, color: ThemeEnum.hover, fontSize: 10),
        const RSizedBox(height: 2),
        SemiBoldText(value, color: color, fontSize: 13),
      ],
    );
  }
}
